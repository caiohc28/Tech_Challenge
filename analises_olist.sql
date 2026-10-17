-- =====================================================================
-- Tech Challenge - Fase 1 | Análise do e-commerce Olist
-- Banco de dados: PostgreSQL (Supabase)
-- Fonte: Brazilian E-Commerce Public Dataset by Olist (Kaggle)
-- =====================================================================
-- Pré-requisitos
--   1. Tabelas carregadas no banco com o script importar_dados.py
--   2. View orders_delivered criada (item 0.4)
--
-- Organização
--   0. Verificação de qualidade dos dados
--   1. Crescimento e receita
--   2. Logística e SLA
--   3. Satisfação do cliente
--   4. Comportamento e pagamentos
--   5. Oportunidades e recomendação
--
-- =====================================================================


-- =====================================================================
-- 0. VERIFICAÇÃO DE QUALIDADE DOS DADOS
-- Objetivo: identificar nulos, duplicidades e status de pedido antes das
-- análises de negócio.
-- =====================================================================

-- 0.1 | Pedidos sem data de aprovação ou sem data de entrega
select count(*) filter (where order_approved_at is null) as sem_aprovacao,
       count(*) filter (where order_delivered_customer_date is null) as sem_entrega,
       count(*) as total
from orders;
-- Resultado: 160 sem aprovação; 2.965 sem entrega; 99.441 pedidos no total.

-- 0.2 | Duplicidade de order_id na tabela orders
select order_id, count(*)
from orders
group by order_id
having count(*) > 1;
-- Resultado: nenhuma linha retornada (não há pedidos duplicados).

-- 0.3 | Status de pedido existentes na base
select distinct order_status from orders;
-- Resultado: shipped, unavailable, invoiced, created, approved,
-- processing, delivered e canceled.

-- 0.4 | View com a base de análise (pedidos entregues e com datas completas)
-- Critério: status "delivered", com data de aprovação e data de entrega
-- preenchidas.
create or replace view orders_delivered as
select *
from orders
where order_status = 'delivered'
  and order_approved_at is not null
  and order_delivered_customer_date is not null;

-- 0.5 | Tamanho da base de análise
select count(*) from orders_delivered;
-- Resultado: 96.456 pedidos.

-- 0.6 | Produtos sem categoria
select count(*) filter (where product_category_name is null) as sem_categoria,
       count(*) as total
from products;
-- Resultado: 610 de 32.951 produtos (1,85%) sem categoria.

-- 0.7 | Distribuição das notas de avaliação
select review_score, count(*)
from order_reviews
group by review_score
order by review_score;
-- Resultado: nota 1: 11.424 | nota 2: 3.151 | nota 3: 8.179 |
-- nota 4: 19.142 | nota 5: 57.328.

-- 0.8 | Formas de pagamento: volume e valor médio
select payment_type, count(*), avg(payment_value)
from payments
group by payment_type
order by count(*) desc;
-- Resultado: credit_card 76.795 | boleto 19.784 | voucher 5.775 |
-- debit_card 1.529 | not_defined 3 (valor zero, desconsiderado nas análises).


-- =====================================================================
-- 1. CRESCIMENTO E RECEITA
-- Objetivo: entender a evolução das vendas, o desempenho por categoria e
-- a distribuição geográfica da receita e do frete.
-- =====================================================================

-- 1.1 | Evolução mensal de pedidos, receita e ticket médio por pedido
select
    date_trunc('month', o.order_purchase_timestamp::timestamp) as mes,
    count(distinct o.order_id) as total_pedidos,
    sum(oi.price) as receita_produtos,
    sum(oi.freight_value) as receita_frete,
    round((sum(oi.price) / count(distinct o.order_id))::numeric, 2) as ticket_medio
from orders_delivered o
join order_items oi on o.order_id = oi.order_id
group by mes
order by mes;
-- Resultado: operação piloto entre set e dez/2016 (1 pedido em set/2016 e
-- nenhum pedido entregue em nov/2016). Crescimento acelerado a partir de
-- jan/2017 (748 pedidos), com pico em nov/2017 (mais de 7 mil pedidos).
-- Em 2018, o volume se estabiliza entre cerca de 6 mil e 7 mil pedidos/mês.

-- 1.1b | Faixa do ticket médio por pedido (menor e maior valor mensal)
-- Critério: considera apenas os meses a partir de jan/2017, excluindo a
-- fase piloto de 2016.
select
    round(min(t)::numeric, 2) as ticket_min,
    round(max(t)::numeric, 2) as ticket_max
from (
    select date_trunc('month', o.order_purchase_timestamp::timestamp) as mes,
           sum(oi.price) / count(distinct o.order_id) as t
    from orders_delivered o
    join order_items oi on o.order_id = oi.order_id
    where o.order_purchase_timestamp::timestamp >= '2017-01-01'
    group by mes
) x;
-- Resultado: de R$ 124,38 a R$ 149,35.

-- 1.2 | Receita por categoria de produto (top 15)
select
    coalesce(ct.product_category_name_english, p.product_category_name, 'sem_categoria') as categoria,
    count(distinct o.order_id) as total_pedidos,
    round(sum(oi.price)::numeric, 2) as receita_produtos,
    round(avg(oi.price)::numeric, 2) as preco_medio_item
from orders_delivered o
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
left join category_translation ct on p.product_category_name = ct.product_category_name
group by categoria
order by receita_produtos desc
limit 15;
-- Resultado: health_beauty lidera (R$ 1,23 mi; preço médio por item R$ 130).
-- watches_gifts fatura R$ 1,17 mi com preço médio por item de R$ 199.
-- bed_bath_table tem 9.271 pedidos e preço médio por item de R$ 93.

-- 1.3 | Receita e peso do frete por estado do cliente
select
    c.customer_state as uf,
    count(distinct o.order_id) as total_pedidos,
    round(sum(oi.price)::numeric, 2) as receita_produtos,
    round(sum(oi.freight_value)::numeric, 2) as receita_frete,
    round((sum(oi.freight_value) / sum(oi.price) * 100)::numeric, 2) as frete_pct_receita
from orders_delivered o
join order_items oi on o.order_id = oi.order_id
join customers c on o.customer_id = c.customer_id
group by c.customer_state
order by receita_produtos desc;
-- Resultado: SP concentra R$ 5.065.984 em receita de produtos (RJ: R$ 1.759.473).
-- O frete equivale a 13,85% do valor dos produtos em SP.

-- 1.4 | Estados com maior peso do frete sobre o valor dos produtos
select
    c.customer_state as uf,
    count(distinct o.order_id) as total_pedidos,
    round(sum(oi.price)::numeric, 2) as receita_produtos,
    round((sum(oi.freight_value) / sum(oi.price) * 100)::numeric, 2) as frete_pct_receita
from orders_delivered o
join order_items oi on o.order_id = oi.order_id
join customers c on o.customer_id = c.customer_id
group by c.customer_state
order by frete_pct_receita desc
limit 10;
-- Resultado: RR lidera (28,08%), seguido por MA, RO, AM, SE, PI, TO e AC, todos
-- da região Norte ou Nordeste.

-- 1.5 | Vendedores por estado e pedidos atendidos
select
    s.seller_state as uf_seller,
    count(distinct s.seller_id) as total_sellers,
    count(distinct oi.order_id) as pedidos_atendidos
from sellers s
join order_items oi on s.seller_id = oi.seller_id
group by s.seller_state
order by total_sellers desc;
-- Resultado: SP concentra 1.849 vendedores, seguido por PR (349), MG (244),
-- SC (190), RJ (171) e RS (129). Os estados do Norte com maior frete e prazo
-- não aparecem entre os de maior número de vendedores.


-- =====================================================================
-- 2. LOGÍSTICA E SLA
-- Objetivo: medir o tempo de entrega e o cumprimento do prazo prometido.
-- =====================================================================

-- 2.1 | Lead time (compra até entrega ao cliente), em dias
select
    round(avg(extract(epoch from (order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp)) / 86400)::numeric, 1) as lead_time_medio_dias,
    round(min(extract(epoch from (order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp)) / 86400)::numeric, 1) as lead_time_min,
    round(max(extract(epoch from (order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp)) / 86400)::numeric, 1) as lead_time_max
from orders_delivered;
-- Resultado: média de 12,6 dias; mínimo de 0,5 dia; máximo de 209,6 dias.

-- 2.2 | Cumprimento do prazo estimado de entrega
select
    count(*) filter (where order_delivered_customer_date::timestamp <= order_estimated_delivery_date::timestamp) as no_prazo,
    count(*) filter (where order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp) as atrasado,
    round(
        100.0 * count(*) filter (where order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp) / count(*),
        2
    ) as pct_atraso
from orders_delivered;
-- Resultado: 88.630 pedidos no prazo; 7.826 atrasados (8,11% de 96.456).

-- 2.3 | Lead time médio por estado do cliente (10 maiores prazos)
select
    c.customer_state as uf,
    round(avg(extract(epoch from (o.order_delivered_customer_date::timestamp - o.order_purchase_timestamp::timestamp)) / 86400)::numeric, 1) as lead_time_medio_dias,
    count(*) as total_pedidos
from orders_delivered o
join customers c on o.customer_id = c.customer_id
group by c.customer_state
order by lead_time_medio_dias desc
limit 10;
-- Resultado: RR (29,4 dias), AP (27,2), AM (26,4), AL (24,5), PA (23,8),
-- MA (21,6), SE (21,5), CE (21,3), AC (21,0) e PB (20,4). Todos os dez estados
-- são das regiões Norte e Nordeste.


-- =====================================================================
-- 3. SATISFAÇÃO DO CLIENTE
-- Objetivo: identificar os fatores associados à nota de avaliação.
-- =====================================================================

-- 3.1 | Nota média: pedidos entregues no prazo vs. com atraso
select
    case
        when o.order_delivered_customer_date::timestamp > o.order_estimated_delivery_date::timestamp then 'atrasado'
        else 'no_prazo'
    end as situacao_entrega,
    round(avg(r.review_score)::numeric, 2) as nota_media,
    count(*) as total_pedidos
from orders_delivered o
join order_reviews r on o.order_id = r.order_id
group by situacao_entrega;
-- Resultado: atrasado 2,57 (7.700 avaliações) | no prazo 4,29 (88.639
-- avaliações). Diferença de 1,72 ponto.

-- 3.2 | Nota média por categoria de produto (15 menores notas)
-- Critério: apenas categorias com 100 avaliações ou mais.
select
    coalesce(ct.product_category_name_english, p.product_category_name, 'sem_categoria') as categoria,
    round(avg(r.review_score)::numeric, 2) as nota_media,
    count(*) as total_avaliacoes
from orders_delivered o
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
left join category_translation ct on p.product_category_name = ct.product_category_name
join order_reviews r on o.order_id = r.order_id
group by categoria
having count(*) >= 100
order by nota_media asc
limit 15;
-- Resultado: entre as 15 categorias de menor nota, a média varia de 3,52
-- (office_furniture) a 4,05 (fashion_underwear_beach).

-- 3.3 | Nota média: avaliações com e sem comentário
select
    case when review_comment_message is null or trim(review_comment_message) = '' then 'sem_comentario' else 'com_comentario' end as tipo_review,
    round(avg(review_score)::numeric, 2) as nota_media,
    count(*) as total
from order_reviews
group by tipo_review;
-- Resultado: com comentário 3,67 (40.968 avaliações) | sem comentário 4,38
-- (58.256 avaliações).

-- 3.4 | Nota média por tempo de aprovação do pedido
select
    case
        when extract(epoch from (o.order_approved_at::timestamp - o.order_purchase_timestamp::timestamp)) / 3600 <= 1 then 'ate_1h'
        when extract(epoch from (o.order_approved_at::timestamp - o.order_purchase_timestamp::timestamp)) / 3600 <= 24 then '1h_a_24h'
        else 'mais_24h'
    end as tempo_aprovacao,
    round(avg(r.review_score)::numeric, 2) as nota_media,
    count(*) as total_pedidos
from orders_delivered o
join order_reviews r on o.order_id = r.order_id
group by tempo_aprovacao
order by nota_media desc;
-- Resultado: até 1h 4,17 | de 1h a 24h 4,16 | mais de 24h 4,11.


-- =====================================================================
-- 4. COMPORTAMENTO E PAGAMENTOS
-- Objetivo: entender o parcelamento, o valor das compras e a recorrência
-- dos clientes.
-- =====================================================================

-- 4.1 | Valor médio do pagamento por número de parcelas (cartão de crédito)
select
    payment_installments as parcelas,
    round(avg(payment_value)::numeric, 2) as valor_medio,
    count(*) as total_pagamentos
from payments
where payment_type = 'credit_card'
group by parcelas
order by parcelas;
-- Resultado: o valor médio tende a crescer com o número de parcelas, de
-- R$ 95,87 em 1x a R$ 415,09 em 10x. Acima de 10x o volume é pequeno
-- (11x: 23 pagamentos).

-- 4.2 | Clientes com maior valor total de compras (top 20)
-- Critério: o cliente é identificado por customer_unique_id.
select
    c.customer_unique_id,
    count(distinct o.order_id) as frequencia,
    round(sum(oi.price)::numeric, 2) as valor_total,
    max(o.order_purchase_timestamp::timestamp) as ultima_compra
from orders_delivered o
join order_items oi on o.order_id = oi.order_id
join customers c on o.customer_id = c.customer_id
group by c.customer_unique_id
order by valor_total desc
limit 20;
-- Resultado: a maioria dos clientes do ranking realizou uma única compra de
-- valor elevado.

-- 4.3 | Clientes de compra única vs. recorrentes
select
    case when total_pedidos = 1 then 'compra_unica' else 'recorrente' end as tipo_cliente,
    count(*) as total_clientes,
    round(100.0 * count(*) / sum(count(*)) over (), 2) as percentual
from (
    select c.customer_unique_id, count(distinct o.order_id) as total_pedidos
    from orders_delivered o
    join customers c on o.customer_id = c.customer_id
    group by c.customer_unique_id
) sub
group by tipo_cliente;
-- Resultado: compra única 90.537 clientes (97,00%) | recorrentes 2.800
-- clientes (3,00%).


-- =====================================================================
-- 5. OPORTUNIDADES E RECOMENDAÇÃO
-- Objetivo: cruzar a demanda dos clientes com a oferta local de vendedores
-- e identificar oportunidades de venda cruzada.
-- =====================================================================

-- 5.1 | Demanda de clientes vs. vendedores locais, por estado
-- Critério: pedidos_por_seller é nulo quando o estado não tem vendedores.
select
    c.customer_state as uf,
    count(distinct o.order_id) as pedidos_clientes,
    coalesce(s.total_sellers, 0) as sellers_no_estado,
    round(count(distinct o.order_id)::numeric / nullif(s.total_sellers, 0), 1) as pedidos_por_seller
from orders_delivered o
join customers c on o.customer_id = c.customer_id
left join (
    select seller_state, count(distinct seller_id) as total_sellers
    from sellers
    group by seller_state
) s on c.customer_state = s.seller_state
group by c.customer_state, s.total_sellers
order by pedidos_por_seller desc nulls first
limit 15;
-- Resultado: RR (41 pedidos), AL (397), TO (274) e AP (67) não têm vendedores
-- locais. PA (946 pedidos), MA (716) e PI (476) têm 1 vendedor cada.
-- MT (886 pedidos, 4 vendedores), PE (1.593 pedidos, 9 vendedores),
-- BA (3.256 pedidos, 19 vendedores) e SE (335 pedidos, 2 vendedores)
-- também têm demanda alta frente à oferta local.

-- 5.2 | Pares de categorias comprados juntos no mesmo pedido (top 10)
select
    least(ct1.product_category_name_english, ct2.product_category_name_english) as categoria_a,
    greatest(ct1.product_category_name_english, ct2.product_category_name_english) as categoria_b,
    count(distinct oi1.order_id) as pedidos_juntos
from order_items oi1
join order_items oi2 on oi1.order_id = oi2.order_id and oi1.product_id < oi2.product_id
join products p1 on oi1.product_id = p1.product_id
join products p2 on oi2.product_id = p2.product_id
join category_translation ct1 on p1.product_category_name = ct1.product_category_name
join category_translation ct2 on p2.product_category_name = ct2.product_category_name
where ct1.product_category_name_english != ct2.product_category_name_english
group by categoria_a, categoria_b
order by pedidos_juntos desc
limit 10;
-- Resultado: o par mais frequente é bed_bath_table + furniture_decor (70
-- pedidos), seguido de bed_bath_table + home_confort (43).

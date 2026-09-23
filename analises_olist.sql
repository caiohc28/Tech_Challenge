-- ============================================================
-- TECH CHALLENGE - FASE 01 - OLIST
-- ============================================================

-- ============================================================
-- CHECAGEM DE QUALIDADE DOS DADOS
-- Objetivo: entender nulos, duplicatas e status antes de analisar
-- ============================================================

-- 0.1 - Quantos pedidos estão sem data de aprovação ou sem data de entrega
-- (esperado: pedidos cancelados/não concluídos não têm essas datas preenchidas)
select count(*) filter (where order_approved_at is null) as sem_aprovacao,
       count(*) filter (where order_delivered_customer_date is null) as sem_entrega,
       count(*) as total
from orders;
-- Resultado: 160 sem aprovação, 2.965 sem entrega, de 99.441 pedidos totais

-- 0.2 - Verificar se existe order_id duplicado na tabela orders
select order_id, count(*)
from orders
group by order_id
having count(*) > 1;
-- Resultado: nenhuma linha retornada = não há duplicatas

-- 0.3 - Quais status de pedido existem na base
select distinct order_status from orders;
-- Resultado: shipped, unavailable, invoiced, created, approved,
--            processing, delivered, canceled

-- 0.4 - Criar uma VIEW com só os pedidos "limpos" (entregues e com datas completas)
-- Isso evita repetir esse filtro em toda query daqui pra frente
create view orders_delivered as
select *
from orders
where order_status = 'delivered'
  and order_approved_at is not null
  and order_delivered_customer_date is not null;

-- 0.5 - Conferir quantos pedidos sobraram na view
select count(*) from orders_delivered;
-- Resultado: ~96 mil pedidos (base "limpa" usada em quase todas as análises seguintes)

-- 0.6 - Checar nulos na tabela de produtos (categoria faltante)
select count(*) filter (where product_category_name is null) as sem_categoria,
       count(*) as total
from products;
-- Resultado: 610 de 32.951 produtos sem categoria (~1,85%, volume baixo, não compromete análise)

-- 0.7 - Distribuição das notas de review (visão geral de satisfação)
select review_score, count(*) 
from order_reviews
group by review_score
order by review_score;
-- Resultado: muita nota 5 (57.328) e muita nota 1 (11.424)

-- 0.8 - Formas de pagamento usadas e ticket médio de cada uma
select payment_type, count(*), avg(payment_value)
from payments
group by payment_type
order by count(*) desc;
-- Resultado: cartão de crédito domina (76.795), depois boleto (19.784).
-- Existem 3 registros "not_defined" com valor 0 - inconsistência pontual, ignorável.


-- ============================================================
-- TRILHA 1: CRESCIMENTO E RECEITA
-- Objetivo: entender evolução das vendas, categorias e geografia
-- ============================================================

-- 1.1 - Evolução mensal de pedidos, receita e ticket médio
-- (::timestamp necessário porque a coluna veio como texto na importação)
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
-- Resultado: operação piloto em set/2016 (1 pedido), sem pedidos em nov/2016,
-- crescimento consistente a partir de jan/2017

-- 1.2 - Receita por categoria de produto (top 15)
-- coalesce: usa o nome traduzido em inglês, senão o original, senão "sem_categoria"
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
-- Resultado: health_beauty lidera receita; watches_gifts tem menos pedidos mas
-- ticket alto (R$199) chegando quase no mesmo patamar de receita

-- 1.3 - Receita e peso do frete por estado do cliente
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
-- Resultado: SP concentra R$5,06 milhões (quase 3x o RJ, 2º lugar).
-- Frete pesa 13,85% em SP.

-- 1.4 - Mesma query, mas ordenada pelo % de frete (para achar os piores casos)
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
-- Resultado: RR lidera com 28,08% de frete sobre o valor do produto (2x o de SP).
-- Todo o topo é Norte/Nordeste (RR, MA, RO, AM, SE, PI, TO, AC).

-- 1.5 - Quantidade de sellers por estado e pedidos que eles atendem
select 
    s.seller_state as uf_seller,
    count(distinct s.seller_id) as total_sellers,
    count(distinct oi.order_id) as pedidos_atendidos
from sellers s
join order_items oi on s.seller_id = oi.seller_id
group by s.seller_state
order by total_sellers desc;
-- Resultado: SP tem 1.849 sellers, mais que todos os outros estados somados.
-- Confirma que o frete alto no Norte é reflexo da ausência de sellers locais.


-- ============================================================
-- TRILHA 2: LOGÍSTICA E SLA
-- Objetivo: medir tempo de entrega e cumprimento de prazo
-- ============================================================

-- 2.1 - Lead time (tempo entre compra e entrega): média, mínimo e máximo em dias
-- extract(epoch from ...) / 86400 converte a diferença de timestamps para dias
select 
    round(avg(extract(epoch from (order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp)) / 86400)::numeric, 1) as lead_time_medio_dias,
    round(min(extract(epoch from (order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp)) / 86400)::numeric, 1) as lead_time_min,
    round(max(extract(epoch from (order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp)) / 86400)::numeric, 1) as lead_time_max
from orders_delivered;
-- Resultado: média de 12,6 dias; mínimo 0,5 dias; máximo 209,6 dias (outlier extremo)

-- 2.2 - Percentual de pedidos entregues no prazo vs. atrasados
-- (compara a data real de entrega com a data estimada prometida ao cliente)
select 
    count(*) filter (where order_delivered_customer_date::timestamp <= order_estimated_delivery_date::timestamp) as no_prazo,
    count(*) filter (where order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp) as atrasado,
    round(
        100.0 * count(*) filter (where order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp) / count(*), 
        2
    ) as pct_atraso
from orders_delivered;
-- Resultado: 8,11% dos pedidos chegam atrasados (7.826 de ~96 mil)

-- 2.3 - Lead time médio por estado (onde a entrega demora mais)
select 
    c.customer_state as uf,
    round(avg(extract(epoch from (o.order_delivered_customer_date::timestamp - o.order_purchase_timestamp::timestamp)) / 86400)::numeric, 1) as lead_time_medio_dias,
    count(*) as total_pedidos
from orders_delivered o
join customers c on o.customer_id = c.customer_id
group by c.customer_state
order by lead_time_medio_dias desc
limit 10;
-- Resultado: RR (29,4 dias), AP (27,2), AM (26,4) - mesmos estados do frete alto


-- ============================================================
-- TRILHA 3: SATISFAÇÃO DO CLIENTE
-- Objetivo: identificar o que mais influencia a nota de review
-- ============================================================

-- 3.1 - CRUZAMENTO MAIS IMPORTANTE: nota média de pedidos atrasados vs. no prazo
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
-- Resultado: atrasado = nota 2,57 | no prazo = nota 4,29 (diferença de 1,72 pontos)
-- Esse é o fator com maior impacto na satisfação de todo o estudo.

-- 3.2 - Nota média por categoria de produto
-- having count(*) >= 100 evita que categorias com poucas avaliações distorçam o ranking
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
-- Resultado: faixa estreita (3,52 a 4,05) - categoria tem pouco impacto na satisfação
-- comparado ao atraso de entrega.

-- 3.3 - Nota média: reviews com comentário de texto vs. sem comentário
select 
    case when review_comment_message is null or trim(review_comment_message) = '' then 'sem_comentario' else 'com_comentario' end as tipo_review,
    round(avg(review_score)::numeric, 2) as nota_media,
    count(*) as total
from order_reviews
group by tipo_review;
-- Resultado: com comentário = 3,67 | sem comentário = 4,38
-- Viés de coleta: quem está insatisfeito comenta mais, não é fator causal.

-- 3.4 - Nota média por tempo de aprovação do pedido pelo vendedor
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
-- Resultado: diferença de só 0,06 pontos entre aprovar em 1h ou levar mais de 24h.
-- Fator praticamente irrelevante para a satisfação.


-- ============================================================
-- TRILHA 4: COMPORTAMENTO E PAGAMENTOS
-- Objetivo: entender parcelamento, valor e recorrência de compra
-- ============================================================

-- 4.1 - Ticket médio por número de parcelas (só cartão de crédito)
select 
    payment_installments as parcelas,
    round(avg(payment_value)::numeric, 2) as valor_medio,
    count(*) as total_pagamentos
from payments
where payment_type = 'credit_card'
group by parcelas
order by parcelas;
-- Resultado: quanto mais parcelas, maior o ticket médio (R$95,87 em 1x
-- até R$415,09 em 10x). Volume cai muito acima de 10 parcelas.

-- 4.2 - RFM simplificado: top 20 clientes por valor total gasto
-- usa customer_unique_id porque customer_id muda a cada pedido na Olist
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
-- Resultado: quase todo o top 20 tem frequência = 1 (compra única de alto valor,
-- não fidelização)

-- 4.3 - Percentual de clientes recorrentes vs. compra única
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
-- Resultado: 97% compra única, apenas 3% recorrente. Achado estrutural do negócio.


-- ============================================================
-- TRILHA 5: OPORTUNIDADES E RECOMENDAÇÃO
-- Objetivo: cruzar demanda x oferta de sellers, e cross-sell
-- ============================================================

-- 5.1 - Estados com alta demanda mas poucos (ou nenhum) sellers locais
-- pedidos_por_seller NULL = demanda existe mas não há nenhum seller no estado
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
-- Resultado: RR, AL, TO, AP têm ZERO sellers (dependência total externa).
-- MT, PE, BA, SE têm demanda alta com poucos sellers (melhor oportunidade
-- de expansão, pois já é demanda comprovada).

-- 5.2 - Categorias frequentemente compradas juntas no mesmo pedido (cross-sell)
-- least/greatest evita contar o mesmo par de categorias duas vezes (A-B e B-A)
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
-- Resultado: bed_bath_table + furniture_decor é o par mais comum (70 pedidos juntos).
-- Insight secundário/ilustrativo, não é pilar central do relatório.


-- ============================================================
-- RESUMO GERAL
-- ============================================================
-- 1) Sellers concentrados em SP (1.849) -> quase ausentes no Norte/Nordeste
-- 2) Isso gera frete mais caro (até 28% em RR) e entrega mais lenta (até 29 dias)
--    nessas regiões
-- 3) Atraso na entrega é o fator nº1 de queda de satisfação (nota cai de 4,29
--    para 2,57 - muito mais que qualquer outro fator testado)
-- 4) Apenas 3% dos clientes recompram - uma má experiência de entrega
--    provavelmente custa a chance de uma segunda venda
-- 5) Recomendação: priorizar captação de sellers em mercados já validados
--    (PE, MT, BA, SE) para reduzir frete, prazo, e melhorar satisfação/recompra

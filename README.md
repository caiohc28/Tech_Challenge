# Tech Challenge — Fase 1 | Olist

Projeto desenvolvido na **Pós-Tech Data Analytics — FIAP**, utilizando o *Brazilian E-Commerce Public Dataset by Olist*.

O objetivo é transformar dados transacionais de e-commerce em análises e recomendações que apoiem decisões de gestores e investidores.

## Objetivo do projeto

Analisar o desempenho comercial, a logística, o comportamento de compra e a satisfação dos clientes, identificando gargalos, oportunidades de melhoria e recomendações para o negócio.

Perguntas investigadas:
- Como pedidos e receita evoluem ao longo do tempo?
- Quais categorias e regiões mais contribuem para a receita?
- Onde existem gargalos logísticos e atrasos nas entregas?
- Qual é a relação entre logística e satisfação dos clientes?
- Como os clientes se comportam em relação a pagamentos e recompra?
- Quais oportunidades podem ser priorizadas?

## Dataset

O projeto utiliza o **Brazilian E-Commerce Public Dataset by Olist**, com aproximadamente 100 mil pedidos entre 2016 e 2018.

Principais tabelas:
- `customers`
- `orders`
- `order_items`
- `products`
- `sellers`
- `payments`
- `order_reviews`
- `geolocation`
- `product_category_name_translation`

**Fonte:** Olist / Kaggle  
**Dataset:** [Adicionar link utilizado pelo grupo]

## Equipe

| Integrante | RM | Trilha |
|---|---|---|
| Rodolfo Ariel | RM377343 | Crescimento e Receita |
| Caio Carnetti | RM378267 | Logística e SLA |
| Hélvia de Oliveira | RM378537 | Comportamento e Pagamentos |
| Ana Carolina Queiroz | RM378192 | Satisfação do Cliente |
| Jhonny Bendheim | RM378469 | Oportunidades e Recomendação |

## Trilhas de análise

### 1. Crescimento e Receita

**Responsável:** Rodolfo Ariel

Análise da evolução de pedidos, receita, ticket médio, categorias e distribuição geográfica.

Principais resultados documentados:
- Crescimento mais consistente a partir de 2017.
- Aproximadamente 748 pedidos em janeiro de 2017 e 3.545 em maio de 2017.
- Ticket médio próximo de R$ 137 em 2017 e 2018.
- `health_beauty` lidera em receita.
- `bed_bath_table` se destaca em volume.
- `watches_gifts` apresenta maior preço médio dos itens entre as categorias destacadas.
- São Paulo concentra aproximadamente R$ 5,06 milhões em receita.
- A participação do frete varia de aproximadamente 13,85% em SP a 28,08% em RR.

Notebook: `notebooks/Olist_Crescimento_Receita.ipynb`

### 2. Logística e SLA

**Responsável:** Caio Carnetti

Análise dos prazos de entrega, atrasos, cumprimento do SLA e relação entre desempenho logístico e avaliações dos clientes.

**Status:** Em desenvolvimento.

### 3. Comportamento e Pagamentos

**Responsável:** Hélvia de Oliveira

Análise dos meios de pagamento, parcelamento, comportamento de compra e recompra dos clientes.

Principais resultados documentados:

O cartão de crédito (credit_card) é o método mais utilizado, com mais de 76 mil transações. O boleto vem em segundo lugar, com cerca de 19,7 mil transações. Voucher e cartão de débito (debit_card) aparecem na sequência. A distribuição de meios de pagamento comporta-se com dominância expressiva do Cartão de Crédito (73.92%), seguido pelo Boleto (19.04%), Voucher (5.56%) e Cartão de Débito (1.47%).
O Ticket Médio por Número de Parcelas flutua à medida que o número de parcelas aumenta, evidenciando picos característicos de compras de alto valor parceladas em 10, 15, 20 ou 24 vezes no cartão de crédito. O cálculo da correlação de Pearson foi de 0.33 e a Correlação de Spearman foi de 0,41. No gráfico de dispersão com a linha de tendência (vermelha), percebe-se claramente que compras de maior valor (especialmente acima de R$ 1.000) tendem a se concentrar em números maiores de parcelas (como 10 parcelas). Compras de menor valor ocorrem em qualquer quantidade de parcelas, mas compras de maior valor quase nunca são feitas em poucas parcelas. Portanto, sim, há uma correlação positiva moderada: quanto maior o valor da compra, mais os clientes tendem a parcelar.
RFM: Recência: Mediana de 224 dias sem novas compras, com picos relevantes próximos a 280 dias;
Frequência: Extremamente transacional. A imensa maioria dos clientes possui frequência igual a 1.
Monetização: O ticket acumulado por cliente concentra-se fortemente entre R$ 50,00 e R$$ 50,00 e R$ 150,00, com queda exponencial suave para valores maiores.
Recompra e retenção por coorte: o modelo atual da Olist é altamente dependente da aquisição constante de novos clientes (CAC), já que 94% do faturamento vem de quem compra apenas uma vez.

Notebook: `notebooks/Olist_Crescimento_Receita.ipynb`

### 4. Satisfação do Cliente

**Responsável:** Ana Carolina Queiroz

Análise dos fatores que mais influenciam a nota de avaliação dos clientes: distribuição das notas, atraso na entrega, categoria do produto, comentários e tempo de aprovação do pedido.

Principais resultados documentados:
- As notas 4 e 5 somam cerca de 77% das avaliações; as notas 1 e 2 representam 14,7%, e a nota 1 sozinha pesa 11,5%.
- Pedidos entregues com atraso recebem nota média de 2,57, contra 4,29 dos entregues no prazo: diferença de 1,72 ponto (cerca de 40% a menos), com atrasos em apenas ~8% das avaliações.
- A nota média por categoria varia de 3,52 `office_furniture` a 4,51 `books_general_interest`, diferença de 0,99 ponto, menor que a causada pelo atraso.
- Clientes que escrevem comentário dão nota média de 3,67, contra 4,38 de quem não comenta; 76,5% das avaliações com nota 1 trazem comentário.
- O tempo de aprovação do pedido praticamente não altera a nota (diferença de 0,06 ponto entre as faixas), e cerca de 64% dos pedidos são aprovados em até 1 hora.
- O atraso na entrega é o fator mais associado à queda da satisfação entre os analisados.

Notebook: `notebooks/Olist_Satisfacao_Cliente.ipynb`

### 5. Oportunidades e Recomendação

**Responsável:** Jhonny Bendheim

Identificação de oportunidades de negócio e elaboração de recomendações estratégicas com base nos resultados das análises, cruzando frete, pricing/cross-sell e desempenho de sellers.

Principais resultados documentados:
- Frete crítico concentrado em rotas específicas: São Paulo → Maranhão (maior volume, ~492 pedidos) com frete em 61% do valor do produto e 22 dias de lead time; São Paulo → Roraima, Minas Gerais → Sergipe/Pará e São Paulo → Amazonas com frete entre 53% e 57% e 25 a 30 dias.
- `furniture_decor` e `office_furniture` combinam ticket médio alto com cross-sell orgânico relevante (cerca de 4 em cada 10 pedidos com múltiplos itens); `signaling_and_security` tem a maior taxa de cross-sell entre as categorias analisadas (48%).
- São Paulo concentra os maiores combos categoria-receita do país (`bed_bath_table`, `health_beauty`, `watches_gifts`, `sports_leisure`).
- Entre os sellers com volume relevante (20+ pedidos), 135 têm nota de avaliação acima da mediana mas entrega mais lenta que a mediana — grupo "Potencial travado por logística", de maior alavancagem de curto prazo.

Notebook: `notebooks/Oportunidades_e_Recomendacao.ipynb`

**Status:** Concluído.

## Como executar os notebooks

1. Abra o notebook desejado no Google Colab.
2. Disponibilize os arquivos CSV necessários.
3. Execute as células na ordem apresentada.
4. Consulte os gráficos, tabelas e resultados gerados.

Arquivos utilizados na trilha de Crescimento e Receita:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_products_dataset.csv`
- `olist_customers_dataset.csv`
- `product_category_name_translation.csv`

Arquivos utilizados na trilha de Satisfação do Cliente:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_products_dataset.csv`
- `product_category_name_translation.csv`

Arquivos utilizados na trilha de Oportunidades e Recomendação:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_customers_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_products_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `product_category_name_translation.csv`


## Entregáveis

- Repositório GitHub com os códigos utilizados.
- Relatório executivo.
- Apresentação executiva.
- Vídeo executivo de até 5 minutos.

## Status do projeto

| Etapa | Status |
|---|---|
| Crescimento e Receita | Concluído |
| Logística e SLA | Em desenvolvimento |
| Comportamento e Pagamentos | Em desenvolvimento |
| Satisfação do Cliente | Concluído |
| Oportunidades e Recomendação | Concluído |
| Relatório final | Em desenvolvimento |
| Apresentação final | Em desenvolvimento |
| Vídeo executivo | Em desenvolvimento |

---

*Este README será atualizado conforme as análises forem concluídas e os resultados forem incorporados ao projeto.*

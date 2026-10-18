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
| Hélvia | RM378537 | Comportamento e Pagamentos |
| Ana Carolina | RM378192 | Satisfação do Cliente |
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

**Responsável:** Hélvia

Análise dos meios de pagamento, parcelamento, comportamento de compra e recompra dos clientes.

**Status:** Em desenvolvimento.

### 4. Satisfação do Cliente

**Responsável:** Ana Carolina

Análise das avaliações dos clientes e dos possíveis fatores associados à satisfação.

**Status:** Em desenvolvimento.

### 5. Oportunidades e Recomendação

**Responsável:** Jhonny Bendheim

Identificação de oportunidades de negócio e elaboração de recomendações estratégicas com base nos resultados das análises.

**Status:** Em desenvolvimento.

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
| Satisfação do Cliente | Em desenvolvimento |
| Oportunidades e Recomendação | Em desenvolvimento |
| Relatório final | Em desenvolvimento |
| Apresentação final | Em desenvolvimento |
| Vídeo executivo | Em desenvolvimento |

---

*Este README será atualizado conforme as análises forem concluídas e os resultados forem incorporados ao projeto.*

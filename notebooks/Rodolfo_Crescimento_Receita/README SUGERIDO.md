# Tech Challenge — Fase 1 | Olist

Projeto desenvolvido na **Pós-Tech Data Analytics — FIAP** a partir do _Brazilian E-Commerce Public Dataset by Olist_.

O objetivo é transformar dados transacionais de e-commerce em uma análise executiva, com foco em desempenho comercial, logística, comportamento de compra, satisfação do cliente e oportunidades de negócio.

---

## Objetivo do projeto

Construir uma análise baseada em dados que ajude a responder questões relevantes para investidores e gestores, como:

- Como pedidos e receita evoluíram ao longo do tempo?
- Quais categorias e regiões mais contribuem para a receita?
- Onde existem gargalos logísticos?
- Quais fatores afetam a satisfação do cliente?
- Como os clientes se comportam em relação a pagamento e recompra?
- Quais oportunidades podem ser priorizadas?

---

## Dataset

O projeto utiliza o **Brazilian E-Commerce Public Dataset by Olist**, com aproximadamente **100 mil pedidos entre 2016 e 2018**.

Principais tabelas disponíveis:

- `customers`
- `orders`
- `order_items`
- `products`
- `sellers`
- `payments`
- `order_reviews`
- `geolocation`
- `product_category_name_translation`

> **Fonte:** Olist / Kaggle  
> **Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## Equipe

| Integrante   | Responsabilidade             |
| ------------ | ---------------------------- |
| Rodolfo      | Crescimento e Receita        |
| Caio         | Logística e SLA              |
| Hélvia       | Comportamento e Pagamentos   |
| Ana Carolina | Satisfação do Cliente        |
| Jhonny       | Oportunidades e Recomendação |

---

## Trilhas de análise

### 1. Crescimento e Receita

Análise da evolução de pedidos, receita, ticket médio, categorias e distribuição geográfica.

Principais resultados já documentados:

- crescimento mais consistente a partir de 2017;
- aproximadamente **748 pedidos em jan/2017** e **3.545 em mai/2017**;
- ticket médio próximo de **R$ 137** em 2017 e 2018;
- `health_beauty` lidera a receita;
- `bed_bath_table` se destaca em volume;
- `watches_gifts` apresenta maior preço médio dos itens entre as categorias destacadas;
- São Paulo concentra aproximadamente **R$ 5,06 milhões** em receita;
- o peso do frete varia de aproximadamente **13,85% em SP** para **28,08% em RR**.

Notebook:

```text
notebooks/Olist_Crescimento_Receita.ipynb
```

### 2. Logística e SLA

**Responsável: Caio**

> Em desenvolvimento.

### 3. Comportamento e Pagamentos

**Responsável: Helyia**

> Em desenvolvimento.

### 4. Satisfação do Cliente

**Responsável: Ana Carolina**

> Em desenvolvimento.

### 5. Oportunidades e Recomendação

**Responsável: Jhonny**

> Em desenvolvimento.

---

## Tecnologias utilizadas

- Python
- Pandas
- Matplotlib
- Google Colab
- Git / GitHub

---

## Estrutura sugerida do repositório

```text
Tech_Challenge_Olist/
ainda não definido
```

> A estrutura pode ser ajustada conforme os arquivos finais do grupo.

---

## Como executar os notebooks

1. Abra o notebook desejado no Google Colab.
2. Adicione os CSVs necessários na aba **Arquivos**.
3. Execute as células de cima para baixo.
4. Os gráficos e tabelas serão gerados automaticamente.

Para a trilha de **Crescimento e Receita**, são necessários:

```text
olist_orders_dataset.csv
olist_order_items_dataset.csv
olist_products_dataset.csv
olist_customers_dataset.csv
product_category_name_translation.csv
```

---

## Entregáveis

O projeto final será composto por:

- repositório GitHub com os códigos utilizados;
- relatório executivo;
- apresentação executiva;
- vídeo executivo de até 5 minutos.

---

## Status do projeto

| Etapa                        | Status                |
| ---------------------------- | --------------------- |
| Crescimento e Receita        | ✅ Concluído          |
| Logística e SLA              | 🚧 Em desenvolvimento |
| Comportamento e Pagamentos   | 🚧 Em desenvolvimento |
| Satisfação do Cliente        | 🚧 Em desenvolvimento |
| Oportunidades e Recomendação | 🚧 Em desenvolvimento |
| Relatório final              | 🚧 Em desenvolvimento |
| Apresentação final           | 🚧 Em desenvolvimento |
| Vídeo executivo              | 🚧 Em desenvolvimento |

---

## Observação

Este README será atualizado à medida que as demais trilhas forem concluídas e incorporadas ao repositório.

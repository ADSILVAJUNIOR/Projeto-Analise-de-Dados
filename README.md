# Projeto de Analise de Dados

## Problema de Negocio 

Qual o desempenho de vendas, clientes mais lucrativos e o volume de produtos vendidos, para auxiliar no planejamento de estratégico de marketing e planejamento operacional. 

## O que busca responder

Identificação de Clientes Mais Lucrativos, Análise da Crescimento Anual, Volume de Produtos Vendidos.

## Banco de dados ultilizado
dw_northwind

## Modelo conceitual e Logico

### Modelo Conceitual Feito no BRMODELO: [https://app.brmodeloweb.com/#!/publicview/67916aa96bead34509f96c36](url)

![Image](https://github.com/user-attachments/assets/46ef67ea-d061-4854-a9c1-7d4458a8e6d8)

### Modelo Logico Feito no BRMODELO: [https://app.brmodeloweb.com/#!/publicview/67916c0d6bead34509f96cd6](url)

![Image](https://github.com/user-attachments/assets/c4bd7118-7f2c-4df2-bd06-f4d0cf62e49f)

## sql - Data Warehouse Etl

```-- Criando tabela dim_produto:
CREATE TABLE dw_projeto.dim_produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR,
    categoria VARCHAR
);

-- Inserindo dados na tabela dim_produto:
INSERT INTO dw_projeto.dim_produto (id_produto, nome, categoria) 
SELECT DISTINCT 
    pr.id AS id_produto,
    pr.nome AS nome_produto,
    c.nome AS produto_categoria
FROM public.produtos pr
INNER JOIN categorias c
    ON c.id = pr.id_categoria;

-- Verificando os dados da tabela dim_produto:
SELECT * FROM dw_projeto.dim_produto;

-- Criando tabela dim_tempo:
CREATE TABLE dw_projeto.dim_tempo (
    id SERIAL PRIMARY KEY,
    data DATE NOT NULL, 
    ano INT NOT NULL,
    mes INT NOT NULL,
    dia_da_semana VARCHAR NOT NULL,
    mes_extenso VARCHAR NOT NULL,
    dia INT NOT NULL
);

-- Inserindo dados na tabela dim_tempo:
INSERT INTO dw_projeto.dim_tempo(data, ano, mes, dia, dia_da_semana, mes_extenso)
SELECT
    dt AS data,
    EXTRACT(YEAR FROM dt) AS ano,
    EXTRACT(MONTH FROM dt) AS mes,
    EXTRACT(DAY FROM dt) AS dia,
    TO_CHAR(dt, 'Day') AS dia_da_semana,
    TO_CHAR(dt, 'Month') AS mes_extenso
FROM generate_series(
    CURRENT_DATE - INTERVAL '30 years',
    CURRENT_DATE + INTERVAL '5 years',
    INTERVAL '1 day'
) AS dt;

-- Verificando os dados da tabela dim_tempo:
SELECT * FROM dw_projeto.dim_tempo;

-- Criando tabela dim_clientes:
CREATE TABLE dw_projeto.dim_clientes (
    id SERIAL PRIMARY KEY,
    nome_empresa VARCHAR,
    nome_contato VARCHAR
);

-- Inserindo dados na tabela dim_clientes:
INSERT INTO dw_projeto.dim_clientes (nome_empresa, nome_contato)
SELECT DISTINCT 
    nome_empresa,
    nome_contato
FROM public.clientes;

-- Verificando os dados da tabela dim_clientes:
SELECT * FROM dw_projeto.dim_clientes;

-- Criando tabela fato_pedidos:
CREATE TABLE dw_projeto.fato_pedidos (
    id SERIAL PRIMARY KEY,
    data_pedido VARCHAR(50), 
    valor_total NUMERIC(10, 2), 
    id_dim_cliente INT NOT NULL,
    id_dim_produto INT NOT NULL,
    id_dim_tempo INT NOT NULL
);

-- Inserindo dados na tabela fato_pedidos:
INSERT INTO dw_projeto.fato_pedidos (data_pedido, valor_total, id_dim_cliente, id_dim_produto, id_dim_tempo)
SELECT DISTINCT
    p.data_pedido AS data_pedido,
    (pd.quantidade * pd.preco_unitario * (1 - pd.desconto))::numeric(18,2) AS valor_total,
    dc.id AS id_dim_cliente,
    dp.id AS id_dim_produto,
    dt.id AS id_dim_tempo
FROM pedido_detalhe pd
INNER JOIN pedidos p ON p.id = pd.id_pedido
INNER JOIN clientes c ON c.id = p.id_cliente
INNER JOIN produtos pr ON pr.id = pd.id_produto
INNER JOIN dw_projeto.dim_produto dp ON dp.id_produto = pr.id
INNER JOIN dw_projeto.dim_clientes dc ON dc.nome_empresa = c.nome_empresa
INNER JOIN dw_projeto.dim_tempo dt ON dt.data = p.data_pedido;

-- Verificando os dados da tabela fato_pedidos:
SELECT * FROM dw_projeto.fato_pedidos;
```


## ERD For Schema: dw_projeto

![Image](https://github.com/user-attachments/assets/215b6869-dbee-4a49-8b38-e632dc8f59ff)


## Dashboard Power BI

![Image](https://github.com/user-attachments/assets/93d8029a-fdba-4fe2-bccc-c5d5931fca21)

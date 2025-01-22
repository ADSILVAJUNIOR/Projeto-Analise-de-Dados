--Criando tabela dim_produto:
CREATE TABLE dw_projeto.dim_produto (
		id_produto SERIAL PRIMARY KEY,
		nome VARCHAR,
		categoria VARCHAR 		
)

-- Inserindo dados na tabela dim_produto:
INSERT INTO dw_projeto.dim_produto ( id_produto, nome, categoria) 
SELECT DISTINCT 
		pr.id AS ID,
		pr.nome AS nome_produto,
		c.nome AS produto_categoria
		FROM public.produtos pr
		INNER JOIN categorias c
		ON c.id = pr.id_categoria

--Verificando se os dados foram exportados para tabela dim_produto:	
 SELECT * FROM dw_projeto.dim_produto 

--Criando tabela dim_tempo:
CREATE TABLE dw_projeto.dim_tempo (
		id SERIAL PRIMARY KEY,
		data DATE NOT NULL, 
		ano INT NOT NULL,
		mes INT NOT NULL,
		dia_da_semana  VARCHAR NOT NULL,
		mes_extenso  VARCHAR NOT NULL,
		dia INT NOT NULL
 )

---- Inserindo dados na tabela dim_tempo:
INSERT INTO dw_projeto.dim_tempo(data, ano, mes, dia, dia_da_semana, mes_extenso)
SELECT
dt as data,
 EXTRACT(YEAR FROM dt) AS ano,
 EXTRACT(MONTH FROM dt) AS mes,
 EXTRACT(DAY FROM dt) AS dia,
 TO_CHAR(dt, 'Day') AS dia_da_semana,
 TO_CHAR(dt, 'Month') AS mes_extenso
FROM
 generate_series(CURRENT_DATE - INTERVAL '30 years',
CURRENT_DATE + INTERVAL '5 years', INTERVAL '1 day') AS dt

--Verificando se os dados foram exportados para tabela dim_tempo:
SELECT * FROM dw_projeto.dim_tempo

--Criando tabela dim_clientes
 CREATE TABLE dw_projeto.dim_clientes (
		id SERIAL PRIMARY KEY,
		nome_empresa VARCHAR,
		nome_contato VARCHAR
	)

-- Inserindo dados na tabela dim_clientes
INSERT INTO dw_projeto.dim_clientes (nome_empresa, nome_contato)
SELECT DISTINCT nome_empresa,
	   			nome_contato
	FROM public.clientes

--Verificando se os dados foram exportados para tabela dim_clientes
SELECT * FROM dw_projeto.dim_clientes

--criando tabela fato_pedidos:
CREATE TABLE dw_projeto.fato_pedidos (
    id SERIAL PRIMARY KEY,
    data_pedido VARCHAR(50), 
    valor_total NUMERIC(10, 2), 
    id_dim_cliente INT NOT NULL,
    id_dim_produto INT NOT NULL,
    id_dim_tempo INT NOT NULL
)

-- Inserindo dados na tabela fato_pedidos:	
INSERT INTO dw_projeto.fato_pedidos (data, valor_total, id_dim_cliente, id_dim_produto, id_dim_tempo)
SELECT DISTINCT
    p.data_pedido AS data,
    (pd.quantidade * pd.preco_unitario * (1 - pd.desconto))::numeric(18,2) AS valor_total,
    dc.id AS id_dim_cliente,
    dp.id AS id_dim_produto,
    dt.id AS id_dim_tempo
FROM pedido_detalhe pd
INNER JOIN pedidos p ON p.id = pd.id_pedido
INNER JOIN clientes c ON c.id = p.id_cliente
INNER JOIN produtos pr ON pr.id = pd.id_produto
INNER JOIN dw_projeto.dim_produto dp ON dp.id = pd.id_produto
INNER JOIN dw_projeto.dim_clientes dc ON dc.nome_empresa = c.nome_empresa
INNER JOIN dw_projeto.dim_tempo dt ON dt.data = p.data_pedido

--Verificando se os dados foram exportados para tabela:
SELECT * FROM dw_projeto.fato_pedidos


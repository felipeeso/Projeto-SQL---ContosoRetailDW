USE ContosoRetailDW

-- Faturamento mês a mês
SELECT 
	MONTH(S.DateKey) AS 'MES'
	,SUM(S.SalesAmount) AS 'FATURAMENTO MENSAL'
FROM FactOnlineSales S
WHERE YEAR(S.DateKey) = 2008
GROUP BY MONTH(S.DateKey)

-- Produtos com maior faturamento em 2008
SELECT
	S.ProductKey 
	,P.ProductName AS 'NOME PRODUTO'
	,SUM(S.SalesAmount) AS 'FATUMENTO PRODUTO'
FROM FactOnlineSales S
INNER JOIN DimProduct P ON P.ProductKey = S.ProductKey
WHERE YEAR(S.DateKey) = 2008
GROUP BY S.ProductKey, P.ProductName
ORDER BY [FATUMENTO PRODUTO] DESC

-- Categorias de produto com maior faturamento em 2008
SELECT
	PC.ProductCategoryName
	,SUM(S.SalesAmount) AS 'FATUMENTO CATEGORIA'
FROM FactOnlineSales S
INNER JOIN DimProduct P ON P.ProductKey = S.ProductKey
INNER JOIN DimProductSubcategory PS ON PS.ProductSubcategoryKey = P.ProductSubcategoryKey
INNER JOIN DimProductCategory PC ON PC.ProductCategoryKey = PS.ProductCategoryKey
WHERE YEAR(S.DateKey) = 2008
GROUP BY PC.ProductCategoryName
ORDER BY [FATUMENTO CATEGORIA] DESC

-- Paises que geraram maior faturamento para a empresa em 2008
SELECT 
	RegionCountryName
	,SUM(S.SalesAmount) AS 'VALOR POR PAÍS'
FROM FactOnlineSales S
INNER JOIN DimStore L ON L.StoreKey = S.StoreKey
INNER JOIN DimGeography G ON G.GeographyKey = L.GeographyKey
WHERE YEAR(S.DateKey) = 2008
GROUP BY RegionCountryName
ORDER BY RegionCountryName DESC

-- Clientes que mais gastaram em 2008
SELECT 
	S.CustomerKey
	,C.FirstName + ' ' + C.LastName AS 'NOME CLIENTE'
	,SUM(S.SalesAmount) AS 'GASTO POR CLIENTE'
FROM FactOnlineSales S
INNER JOIN DimCustomer C ON C.CustomerKey = S.CustomerKey
WHERE YEAR(S.DateKey) = 2008 AND C.FirstName IS NOT NULL
GROUP BY S.CustomerKey, C.FirstName + ' ' + C.LastName
ORDER BY [GASTO POR CLIENTE] DESC

-- Vendas por gênero
SELECT 
	C.Gender
	,SUM(S.SalesAmount) AS 'GASTO POR GÊNERO'
FROM FactOnlineSales S
INNER JOIN DimCustomer C ON C.CustomerKey = S.CustomerKey
WHERE YEAR(S.DateKey) = 2008 
GROUP BY C.Gender
ORDER BY [GASTO POR GÊNERO] DESC

-- FAIXA ETÁRIA DOS PRINCIPAIS CLIENTES
WITH TABELA (NOME_CLIENTE, ANO_NASCIMENTO, IDADE, GASTO_POR_CLIENTE)
AS
(
SELECT 
	C.FirstName + ' ' + C.LastName AS NOME_CLIENTE
	,YEAR(C.BirthDate) AS ANO_NASCIMENTO
	,2008 - YEAR(C.BirthDate) AS IDADE
	,SUM(S.SalesAmount) AS GASTO_POR_CLIENTE
FROM FactOnlineSales S
INNER JOIN DimCustomer C ON C.CustomerKey = S.CustomerKey
WHERE YEAR(S.DateKey) = 2008 AND C.FirstName IS NOT NULL
GROUP BY S.CustomerKey, C.FirstName + ' ' + C.LastName, YEAR(C.BirthDate)
)

SELECT TOP 10
	NOME_CLIENTE
	,IDADE
	,GASTO_POR_CLIENTE
	,CASE
		WHEN IDADE BETWEEN 18 AND 30 THEN '18-30'
		WHEN IDADE BETWEEN 31 AND 59 THEN '31-59'
		WHEN IDADE >= 60 THEN '60+'
	END AS FAIXA_ETARIA
FROM TABELA
ORDER BY [GASTO_POR_CLIENTE] DESC
DECLARE @FromDate SMALLDATETIME
DECLARE @ToDate SMALLDATETIME 


IF %FromDate% <> '0' SET @FromDate = %FromDate%
IF %ToDate% <> '0' SET @ToDate = %ToDate%


DECLARE @FromDateLY SMALLDATETIME = DATEADD(YEAR,-1,@FromDate)
DECLARE @ToDateLY SMALLDATETIME = DATEADD(YEAR,-1,@ToDate)


DECLARE @SalesYTD TABLE
(
CustomerID INT,
CustomerCode VARCHAR(50),
Name VARCHAR(100),
TotalSalesYTD MONEY,
TotalCostYTD MONEY,
MarginYTD MONEY,
TotalSalesPY MONEY,
TotalCostPY MONEY,
MarginPY MONEY
)

INSERT INTO @SalesYTD (CustomerID,CustomerCode,Name,TotalSalesYTD,TotalCostYTD,MarginYTD,TotalSalesPY,TotalCostPY,MarginPY)
SELECT C.CustomerID,C.CustomerCode, C.Name,
--TotalSalesYTD
ISNULL((SELECT SUM(SA.TotalSales) FROM SalesAnalysis3 SA
WHERE C.CustomerID = SA.CustomerID AND DocumentDate BETWEEN @FromDate AND @ToDate), 0),
--TotalCostYTD
ISNULL((SELECT SUM(SA.TotalCost) FROM SalesAnalysis3 SA
WHERE C.CustomerID = SA.CustomerID AND DocumentDate BETWEEN @FromDate AND @ToDate), 0),
--MarginYTD
ISNULL((SELECT SUM(SA.TotalSales-SA.TotalCost) FROM SalesAnalysis3 SA 
WHERE C.CustomerID = SA.CustomerID AND DocumentDate BETWEEN @FromDate AND @ToDate), 0),
--TotalSalesPY
ISNULL((SELECT SUM(SA.TotalSales) FROM SalesAnalysis3 SA 
WHERE C.CustomerID = SA.CustomerID AND DocumentDate BETWEEN @FromDateLY AND @ToDateLY), 0),
--totalcostLTYD
ISNULL((SELECT SUM(SA.TotalCost) FROM SalesAnalysis3 SA
WHERE C.CustomerID = SA.CustomerID AND DocumentDate BETWEEN @FromDateLY AND @ToDateLY), 0),
--MarginPY
ISNULL((SELECT SUM(SA.TotalSales-SA.TotalCost) FROM SalesAnalysis3 SA 
WHERE C.CustomerID = SA.CustomerID AND DocumentDate BETWEEN @FromDateLY AND @ToDateLY), 0)


FROM Customer C
GROUP BY C.CustomerID, C.CustomerCode, C.Name

SELECT 
CustomerCode,
Name, 
TotalSalesYTD, 
TotalCostYTD, 
MarginYTD, 
NULLIF(MarginYTD,0)/NULLIF(TotalSalesYTD,0) [Mrg%YTD], 
TotalSalesPY, 
TotalCostPY, 
MarginPY, 
NULLIF(MarginPY,0)/NULLIF(TotalSalesPY,0) [Mrg%PY]
FROM @SalesYTD 
ORDER BY TotalSalesYTD DESC
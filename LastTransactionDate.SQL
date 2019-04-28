
DECLARE @LastTransactionDate NUMERIC

IF %LastTransactionDate% <> '0' SET @LastTransactionDate = %LastTransactionDate%

DECLARE @SlowMovingItems TABLE (
  ProductID int,
  ProductGroupID int,
  ProductCode varchar(100),
  Description varchar(250),
  InStock decimal(12, 2),
  StockTransactionDateOut datetime,
  StockTransactionDateIn datetime
)

INSERT INTO @SlowMovingItems (ProductID,
ProductGroupID,
ProductCode,
Description,
InStock,
StockTransactionDateOut,
StockTransactionDateIn)
  SELECT
    P.ProductID,
    P.ProductGroupID,
    P.ProductCode,
    P.Description,

    ISNULL((SELECT
      S.StockActual
    FROM Stock S WITH (NOLOCK)
    WHERE P.ProductID = S.ProductID
    AND S.BranchID = 0
    AND SUM(P.Deleted) = 0), 0),

    (SELECT
      MAX(ST.StockTransactionDate)
    FROM StockTransaction ST WITH (NOLOCK)
    WHERE ST.ProductID = P.ProductID
    AND (ST.StockTransactionType = 12)),

    (SELECT
      MAX(ST.StockTransactionDate)
    FROM StockTransaction ST
    WHERE ST.ProductID = P.ProductID
    AND (ST.StockTransactionType = 6
    OR ST.StockTransactionType = 31
    OR ST.StockTransactionType = 32
    OR ST.StockTransactionType = 33))


  FROM Product P
  GROUP BY P.ProductCode,
           P.Description,
           P.ProductID,
           P.ProductGroupID
SELECT
  ProductCode [Product Code],
  SMI.Description,
  SMI.InStock [In Stock],
  DATEDIFF(DAY, SMI.StockTransactionDateOut, GETDATE()) [Removed from Stock],
  DATEDIFF(DAY, SMI.StockTransactionDateIn, GETDATE()) [Added to Stock],
  PG1.Name [Product Group]


FROM @SlowMovingItems SMI
LEFT JOIN ProductGroup AS PG WITH (NOLOCK)
  ON PG.ProductGroupID = SMI.ProductGroupID
LEFT JOIN ProductGroup AS PG1 WITH (NOLOCK)
  ON PG1.ProductGroupID = PG.Level1ID

WHERE inStock <> 0
AND DATEDIFF(DAY, SMI.StockTransactionDateOut, GETDATE()) >= @LastTransactionDate
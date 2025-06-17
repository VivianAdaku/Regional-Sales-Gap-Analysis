select top 5*
from [Sample - Superstore]

--checking for duplicates
WITH DuplicateRows AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Order_ID, Product_ID, Quantity, Sales, Profit
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM [Sample - Superstore]
)
DELETE FROM DuplicateRows
WHERE rn > 1;

--checking and replacing null values
select
COUNT(*) as total_rows,
COUNT(CASE WHEN Row_ID IS NULL THEN 1 END) AS null_Row_ID,
COUNT(CASe WHEN Order_ID IS NULL THEN 1 END) AS null_Order_ID,
count(CASE WHEN Order_Date IS NULL THEN 1 END) AS null_Order_Date,
count(CASE WHEN Customer_ID IS NULL THEN 1 END) AS null_Customer_ID,
count(CASE WHEN Customer_Name IS NULL THEN 1 END) AS null_Customer_Name,
count(CASE WHEN Segment IS NULL THEN 1 END) AS null_Segment,
count(CASE WHEN Country IS NULL THEN 1 END) AS null_Country,
count(CASE WHEN City IS NULL THEN 1 END) AS null_City,
count(CASE WHEN State IS NULL THEN 1 END) AS null_State,
count(CASE WHEN Region IS NULL THEN 1 END) AS null_Region,
count(CASE WHEN Product_ID IS NULL THEN 1 END) AS null_Product_ID,
count(CASE WHEN Category IS NULL THEN 1 END) AS null_Category,
count(CASE WHEN Sub_Category IS NULL THEN 1 END) AS null_Sub_Category,
count(CASE WHEN Product_Name IS NULL THEN 1 END) AS null_Product_Name,
count(CASE WHEN Sales IS NULL THEN 1 END) AS null_Sales,
count(CASE WHEN Quantity IS NULL THEN 1 END) AS null_Quantity,
count(CASE WHEN Discount IS NULL THEN 1 END) AS null_Discount,
count(CASE WHEN Profit IS NULL THEN 1 END) AS null_Profit
from dbo.[Sample - Superstore]

--KPI: Sales & Profit per Region/Category
--Goal: Identify lowest-performing segments.

With Regionalcategorysales AS
(SELECT 
  Region, Category,
  YEAR(Order_Date) AS Order_Year,
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit
FROM [Sample - Superstore]
GROUP BY Region, Category, YEAR(Order_Date))
SELECT * FROM Regionalcategorysales;

--KPI: Profit Margin (Profit/Sales)
--Goal: Spot regions/products where sales are high but profit is negative.

WITH HighSalesLowProfitRegion AS
(SELECT 
  Region, Category,
  YEAR(Order_Date) AS Order_Year,
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit,
  ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0), 2) AS Profit_Margin
FROM [Sample - Superstore]
WHERE Sales > 5000 AND Profit < 0
GROUP BY Region, Category,YEAR(Order_Date))
SELECT * FROM HighSalesLowProfitRegion;

--KPI: Quantity sold vs Profit Margin
--Goal: Products that sell a lot but generate little or negative profit


WITH HighSellingLowProfitMarginProducts AS
(SELECT
  Product_Name, Region, Category,
  SUM(Quantity) AS Total_Quantity,
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit,
  ROUND(SUM(Profit) / NULLIF(SUM(Sales),0), 2) AS Profit_Margin
  FROM [Sample - Superstore]
  GROUP BY Product_Name, Category, Region)
  SELECT * FROM HighSellingLowProfitMarginProducts
  WHERE (Total_Profit < 0 AND Total_Sales > 5000);
  
-- ==================================================== OBJECTIVE QUESTIONS ====================================================

-- OBJECTIVE ANSWER 14:	Identify the top 5 most valuable customers using a composite score that combines three key metrics(SQL): 
-- 		a.	Total Revenue (50% weight): The total amount of money spent by the customer.
-- 		b.	Order Frequency (30% weight): The number of orders placed by the customer, indicating their loyalty and engagement.
-- 		c.	Average Order Value (20% weight): The average value of each order placed by the customer, reflecting the typical transaction size.

WITH CustomerMetrics AS ( SELECT CustomerID, 
SUM(SalePrice) AS TotalRevenue, 
COUNT(OrderID) AS OrderFrequency, 
AVG(SalePrice) AS AvgOrderValue 
FROM orders 
GROUP BY CustomerID 
), 
Scored AS ( SELECT *, 
(0.5 * TotalRevenue) + (0.3 * OrderFrequency) + (0.2 * AvgOrderValue) AS CompositeScore 
FROM CustomerMetrics ) 
SELECT *  FROM Scored 
ORDER BY CompositeScore DESC
Limit 5; 

-- OBJECTIVE ANSWER 15: Calculate the month-over-month growth rate in total revenue across the entire dataset(SQL). 
WITH MonthlySales AS ( SELECT  
    EXTRACT(YEAR FROM OrderDate) AS Year, 
    EXTRACT(MONTH FROM OrderDate) AS Month, 
    SUM(SalePrice) AS TotalRevenue 
  FROM Orders 
  GROUP BY Year, Month
) 
SELECT Year, Month, 
  ROUND(TotalRevenue,2) AS TotalRevenue,
  ROUND(((TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY Year, Month)) 
  / LAG(TotalRevenue) OVER (ORDER BY Year, Month) * 100),2)
AS MoM_Growth 
FROM MonthlySales
ORDER BY Year DESC, Month;

-- OBJECTIVE ANSWER 16:	Calculate the rolling 3-month average revenue for each product category(SQL). 
SELECT  
  ProductCategory, 
  EXTRACT(YEAR FROM OrderDate) AS Year,
  EXTRACT(MONTH FROM OrderDate) AS Month,
  Round(AVG(SUM(SalePrice)) OVER ( PARTITION BY ProductCategory  
    ORDER BY EXTRACT(YEAR FROM OrderDate),
  EXTRACT(MONTH FROM OrderDate)
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW 
  ),2) AS Rolling_3M_AvgRevenue 
FROM Orders 
Group BY ProductCategory, Year, Month
Order BY Year, Month; 

-- OBJECTIVE ANSWER 17: Update the orders table to apply a 15% discount on the `Sale Price` for orders placed by customers who have made at least 10 orders(SQL).
UPDATE Orders 
SET SalePrice = Sale_Price * 0.85 
WHERE CustomerID IN ( 
	SELECT CustomerID FROM Orders 
	GROUP BY CustomerID 
	HAVING COUNT(OrderID) >= 10 
);

-- OBJECTIVE ANSWER 18: Calculate the average number of days between consecutive orders for customers who have placed at least five orders(SQL).
WITH OrderDiffs AS ( SELECT CustomerID, OrderDate, OrderID, 
LAG(OrderDate) OVER(PARTITION BY CustomerID 
ORDER BY OrderDate) AS PrevOrder 
FROM orders 
) 
SELECT CustomerID, 
AVG(DATEDIFF(OrderDate,PrevOrder)) AS AvgDaysBetweenOrders 
FROM OrderDiffs 
WHERE PrevOrder  
GROUP BY CustomerID 
HAVING COUNT(OrderID) >= 5;

-- OBJECTIVE ANSWER 19: Identify customers who have generated revenue that is more than 30% higher than the average revenue per customer(SQL).
WITH AvgRev AS ( 
SELECT AVG(CustomerRevenue) AS AvgRevenue 
FROM (SELECT CustomerID, SUM(SalePrice) AS CustomerRevenue 
       FROM Orders GROUP BY CustomerID) tab 
) 
SELECT CustomerID, SUM(SalePrice) AS TotalRevenue 
FROM Orders 
GROUP BY CustomerID 
HAVING TotalRevenue > (SELECT AvgRevenue * 1.3 FROM AvgRev); 

-- OBJECTIVE ANSWER 20: Determine the top 3 product categories that have shown the highest increase in sales over the past year compared to the previous year(SQL).
WITH YearlySales AS (SELECT ProductCategory, 
EXTRACT(YEAR FROM OrderDate) AS Year, 
SUM(SalePrice) AS TotalRevenue 
FROM Orders 
GROUP BY Year, ProductCategory 
) 
SELECT y1.ProductCategory, 
ROUND(y1.TotalRevenue,2) AS CurrentYearSales,
ROUND(y2.TotalRevenue,2) AS PrevYearSales,
ROUND(y1.TotalRevenue - y2.TotalRevenue,2) AS SalesIncrease 
FROM YearlySales y1 
JOIN YearlySales y2 
ON y1.ProductCategory = y2.ProductCategory 
AND y1.Year = y2.Year + 1 
ORDER BY SalesIncrease DESC
LIMIT 3; 

 















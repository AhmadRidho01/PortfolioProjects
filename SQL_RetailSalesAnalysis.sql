SELECT *
FROM [07Desember2024].[dbo].[RetailSalesAnalysis]

-- CREATE STAGING TABLE

select *
into RetailSalesAnalysis_staging
from RetailSalesAnalysis
where 1 = 0;

insert into RetailSalesAnalysis_staging
select * from RetailSalesAnalysis;


-- SALES INFORMATION

SELECT 
    DATEPART(YEAR, sale_date) AS Year,
    DATEPART(MONTH, sale_date) AS Month,
    SUM(total_sale) AS Total_Sales
FROM RetailSalesAnalysis_staging
GROUP BY DATEPART(YEAR, sale_date), DATEPART(MONTH, sale_date)
ORDER BY Year, Month;



-- IDENTIFICATION DUPLICATES

SELECT 
	[transactions_id], [sale_date], [sale_time], [customer_id], [gender], [age],
	[category], [quantiy], [price_per_unit], [cogs], [total_sale], 
    COUNT(*) AS duplicate_count
FROM RetailSalesAnalysis_staging
GROUP BY 
    [transactions_id], [sale_date], [sale_time], [customer_id], [gender], [age],
	[category], [quantiy], [price_per_unit], [cogs], [total_sale]
HAVING COUNT(*) > 1;

-- Data is clean of duplicates


-- LOOK AT NULL VALUES

SELECT 
    SUM(CASE WHEN transactions_id IS NULL THEN 1 ELSE 0 END) AS Transaction_ID_Null,
    SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) AS Sale_Date_Null,
    SUM(CASE WHEN sale_time IS NULL THEN 1 ELSE 0 END) AS Sale_Time_Null,
    SUM(CASE WHEN customer_ID IS NULL THEN 1 ELSE 0 END) AS Customer_ID_Null,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS Gender_Null,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS Age_Null,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS Product_Category_Null,
    SUM(CASE WHEN quantiy IS NULL THEN 1 ELSE 0 END) AS Quantity_Sold_Null,
    SUM(CASE WHEN price_per_unit IS NULL THEN 1 ELSE 0 END) AS Price_Per_Unit_Null,
    SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) AS COGS_Null,
    SUM(CASE WHEN total_sale IS NULL THEN 1 ELSE 0 END) AS Total_Sale_Amount_Null
FROM RetailSalesAnalysis_staging;





-- DATA ANALYSIS
-- MOST FREQUENTLY SOLD PRODUCTS

SELECT 
    category, 
    SUM(quantiy) AS Total_Quantity_Sold
FROM RetailSalesAnalysis_staging
GROUP BY category
ORDER BY Total_Quantity_Sold DESC;


-- CATEGORY WITH THE LARGEST PROFIT MARGIN

SELECT 
    category, 
    SUM(total_sale - cogs) AS Total_Profit
FROM RetailSalesAnalysis_staging
GROUP BY category
ORDER BY Total_Profit DESC;


-- SALES BASED ON GENDER

SELECT 
    gender, 
    SUM(total_sale) AS Total_Sales
FROM RetailSalesAnalysis_staging
GROUP BY gender
ORDER BY Total_Sales DESC;


-- SALES BASED ON AGE

SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END AS Age_Group,
    SUM(total_sale) AS Total_Sales
FROM RetailSalesAnalysis_staging
GROUP BY 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END
ORDER BY Total_Sales DESC;


-- PEAK SALES TIME

SELECT 
    CASE 
        WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning (<12)'
        WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon (12-17)'
        ELSE 'Evening (>17)'
    END AS Sale_Period,
    SUM(total_sale) AS Total_Sales
FROM RetailSalesAnalysis_staging
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning (<12)'
        WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon (12-17)'
        ELSE 'Evening (>17)'
    END
ORDER BY Total_Sales DESC;



-- TREND SALES BASED ON MONTHS

SELECT 
    DATEPART(MONTH, sale_date) AS Month, 
    SUM(total_sale) AS Total_Sales
FROM RetailSalesAnalysis_staging
GROUP BY DATEPART(MONTH, sale_date)
ORDER BY Total_Sales DESC;


-- HIGHEST COGS PRODUCTS

SELECT 
    category, 
    AVG(cogs) AS Avg_COGS
FROM RetailSalesAnalysis_staging
GROUP BY category
ORDER BY Avg_COGS DESC;



-- Total number of transactions made by each gender in each category

SELECT 
    category,
    gender,
    COUNT(transactions_id) AS Total_Transactions,
    (COUNT(transactions_id) * 100.0 / SUM(COUNT(transactions_id)) OVER (PARTITION BY category)) AS Percentage_Contribution
FROM 
    RetailSalesAnalysis_staging
GROUP BY 
    category, gender
ORDER BY 
    category, Total_Transactions DESC;


-- Top 5 customers

SELECT TOP 5
    customer_id,
    SUM(total_sale) AS Total_Sales
FROM 
    RetailSalesAnalysis_staging
GROUP BY 
    customer_id
ORDER BY 
    Total_Sales DESC;

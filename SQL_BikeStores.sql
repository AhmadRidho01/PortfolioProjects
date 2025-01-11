SELECT TOP (1000) [order_id]
      ,[customers]
      ,[city]
      ,[state]
      ,[order_date]
      ,[total_units]
      ,[revenue]
      ,[product_name]
      ,[category_name]
      ,[brand_name]
      ,[store_name]
      ,[sales_rep]
  FROM [07Desember2024].[dbo].[BikeStores_staging]




-- CREATE STAGING TABLE
SELECT *
into BikeStores_staging
from BikeStores
where 1 = 0;

insert into BikeStores_staging
select * from BikeStores;



-- IDENTIFICATION DUPLICATES

SELECT 
	[order_id]
   ,[customers]
   ,[city]
   ,[state]
   ,[order_date]
   ,[total_units]
   ,[revenue]
   ,[product_name]
   ,[category_name]
   ,[brand_name]
   ,[store_name]
   ,[sales_rep]
	  ,
    COUNT(*) AS duplicate_count
FROM BikeStores_staging
GROUP BY 
   [order_id]
   ,[customers]
   ,[city]
   ,[state]
   ,[order_date]
   ,[total_units]
   ,[revenue]
   ,[product_name]
   ,[category_name]
   ,[brand_name]
   ,[store_name]
   ,[sales_rep]
HAVING COUNT(*) > 1;

-- Data is clean of duplicates



-- LOOK AT NULL VALUES

SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS Order_ID_Null,
    SUM(CASE WHEN customers IS NULL THEN 1 ELSE 0 END) AS Customers_Null,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS City_Null,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS State_Null,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS Order_Date_Null,
    SUM(CASE WHEN total_units IS NULL THEN 1 ELSE 0 END) AS Total_Units_Null,
    SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END) AS Revenue_Null,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS Product_Name_Null,
    SUM(CASE WHEN category_name IS NULL THEN 1 ELSE 0 END) AS Category_Name_Null,
    SUM(CASE WHEN brand_name IS NULL THEN 1 ELSE 0 END) AS Brand_Name_Null,
    SUM(CASE WHEN store_name IS NULL THEN 1 ELSE 0 END) AS Store_Name_Null,
	SUM(CASE WHEN sales_rep IS NULL THEN 1 ELSE 0 END) AS Sales_Rep_Null
FROM BikeStores_staging;





-- Sales Analysis by Location
-- Total revenue
SELECT 
    city, 
    state, 
    SUM(revenue) AS total_revenue
FROM 
    BikeStores_staging
GROUP BY 
    city, state
ORDER BY 
    total_revenue DESC;


-- Total units sold
SELECT 
    city, 
    state, 
    SUM(total_units) AS total_units_sold
FROM 
    BikeStores_staging
GROUP BY 
    city, state
ORDER BY 
    total_units_sold DESC;


-- Average revenue per city
SELECT 
    city, 
    state, 
    COUNT(order_id) AS total_orders,
    SUM(revenue) AS total_revenue,
    AVG(revenue) AS avg_revenue_per_order
FROM 
    BikeStores_staging
GROUP BY 
    city, state
ORDER BY 
    avg_revenue_per_order DESC;


-- State
SELECT 
    state, 
    SUM(revenue) AS total_revenue,
    SUM(total_units) AS total_units_sold
FROM 
    BikeStores_staging
GROUP BY 
    state
ORDER BY 
    total_revenue DESC;



-- Product and Category Performance Analysis
-- Total revenue by category
SELECT 
    category_name, 
    SUM(revenue) AS total_revenue,
    SUM(total_units) AS total_units_sold
FROM 
    BikeStores_staging
GROUP BY 
    category_name
ORDER BY 
    total_revenue DESC;


-- Highest selling product
SELECT 
    product_name, 
    category_name,
    SUM(revenue) AS total_revenue,
    SUM(total_units) AS total_units_sold
FROM 
    BikeStores_staging
GROUP BY 
    product_name, category_name
ORDER BY 
    total_units_sold DESC;


-- Average revenue by category
SELECT 
    category_name, 
    SUM(revenue) AS total_revenue,
    SUM(total_units) AS total_units_sold,
    (SUM(revenue) / SUM(total_units)) AS avg_revenue_per_unit
FROM 
    BikeStores_staging
GROUP BY 
    category_name
ORDER BY 
    avg_revenue_per_unit DESC;


-- Highest total revenue by brand
SELECT 
    brand_name, 
    SUM(revenue) AS total_revenue,
    SUM(total_units) AS total_units_sold
FROM 
    BikeStores_staging
GROUP BY 
    brand_name
ORDER BY 
    total_revenue DESC;



-- Store and Sales Representative Performace Analysis
-- Total revenue by store
SELECT 
    store_name, 
    SUM(revenue) AS total_revenue,
    SUM(total_units) AS total_units_sold
FROM 
    BikeStores_staging
GROUP BY 
    store_name
ORDER BY 
    total_revenue DESC;


-- Sales representative performance by revenue
SELECT 
    sales_rep, 
    store_name,
    SUM(revenue) AS total_revenue,
    SUM(total_units) AS total_units_sold
FROM 
    BikeStores_staging
GROUP BY 
    sales_rep, store_name
ORDER BY 
    total_revenue DESC;


-- Average revenue each store
SELECT 
    store_name, 
    COUNT(order_id) AS total_orders,
    SUM(revenue) AS total_revenue,
    (SUM(revenue) / COUNT(order_id)) AS avg_revenue_per_order
FROM 
    BikeStores_staging
GROUP BY 
    store_name
ORDER BY 
    avg_revenue_per_order DESC;


-- Contribution of each store
SELECT 
    store_name, 
    SUM(revenue) AS total_revenue,
    (SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM BikeStores)) AS revenue_contribution_percentage
FROM 
    BikeStores_staging
GROUP BY 
    store_name
ORDER BY 
    revenue_contribution_percentage DESC;



-- Sales Seasonal Analysis
-- Total sales by month
SELECT 
    MONTH(order_date) AS month, 
	COUNT(order_id) AS total_orders,
	SUM(total_units) AS total_units_sold,
    SUM(revenue) AS total_revenue,
	(SUM(revenue) / COUNT(order_id)) AS avg_revenue_per_order
FROM 
    BikeStores_staging
GROUP BY 
    MONTH(order_date)
ORDER BY 
    month;


-- pattern every 3 months
SELECT 
    DATEPART(QUARTER, order_date) AS quarter, 
    SUM(revenue) AS total_revenue,
    SUM(total_units) AS total_units_sold
FROM 
    BikeStores_staging
GROUP BY 
    DATEPART(QUARTER, order_date)
ORDER BY 
    quarter;


-- Total revenue in each season
SELECT 
    CASE 
        WHEN MONTH(order_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(order_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(order_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(order_date) IN (9, 10, 11) THEN 'Fall'
    END AS season,
    SUM(revenue) AS total_revenue,
    SUM(total_units) AS total_units_sold
FROM 
    BikeStores_staging
GROUP BY 
    CASE 
        WHEN MONTH(order_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(order_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(order_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(order_date) IN (9, 10, 11) THEN 'Fall'
    END
ORDER BY 
    season;





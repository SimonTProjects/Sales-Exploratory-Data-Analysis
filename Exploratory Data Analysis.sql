/*============================================================================
SPLIT DATASET INTO [DIMENSION] OR [MEASURE] COLUMN
--------------------------------------------------
E.G.- Is data type numerical?
	YES = [MEASURE] 
		--> Does it make sense to aggregate? 
			YES = [MEASURE]; NO = [DIMENSION]

	NO = [DIMENSION]
============================================================================*/

/*Sales = MEASURE*/
SELECT DISTINCT
sales_amount
FROM gold.fact_sales

/*Product = DIMENSION*/
SELECT DISTINCT
product_name
FROM gold.dim_products

/*Birthdate = DIMENSION*/
SELECT DISTINCT
DATEDIFF(year, birthdate, GETDATE()) AS Age
FROM gold.dim_customers

/*(Age) Average Birthdate = MEASURE*/
SELECT DISTINCT
AVG(DATEDIFF(year, birthdate, GETDATE())) AS Avg_Age
FROM gold.dim_customers

/*ID = DIMENSION*/
SELECT DISTINCT
customer_id
FROM gold.dim_customers

/*============================================================================
(1) Database Exploration
============================================================================*/
-- Explore All Objects
SELECT*FROM INFORMATION_SCHEMA.TABLES

-- Explore All Columns
SELECT*FROM INFORMATION_SCHEMA. COLUMNS

WHERE TABLE_NAME = 'dim_customers' -- 'dim_products'; 'fact_sales'

/*============================================================================
(2) Dimensions Exploration
--------------------------
WHAT? Identify the unique values in each dimension

WHY? To recognise how data might be grouped or segmented
============================================================================*/
-- Explore customer countries'
SELECT DISTINCT country FROM gold.dim_customers

-- Explore  product categories
SELECT DISTINCT category FROM gold.dim_products
SELECT DISTINCT category, subcategory FROM gold.dim_products
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1,2,3

/*============================================================================
(3) Date Exploration
--------------------
WHAT? Indentify boundaries: the earliest and latests dates

WHY? To understand the scope of data and the timespan

HOW? Range:
	MIN/MAX = [Date Dimension]
	MIN = order_date
	MIN = Birthdate
	MAX = create_date
	DATEDIFF
============================================================================*/
-- First order; last order; range
SELECT 
MIN(order_date) AS first_order_date, 
MAX(order_date) AS last_order_date,
DATEDIFF(year, MIN(order_date), MAX(order_date)) AS year_range
FROM gold.fact_sales

-- Find youngest and oldest customer
SELECT
MIN(birthdate) AS oldest_birthdate,
MAX(birthdate) AS youngest_birthdate
FROM gold.dim_customers
	-- Age
SELECT
MIN(birthdate) AS oldest_birthdate,
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
MAX(birthdate) AS youngest_birthdate,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers

/*============================================================================
(4) Measures Exploration
------------------------
WHAT? Calculate key metrics (Big Numbers)

WHY? Totals

HOW? Aggregation:
	COUNT
	SUM(Sales)
	SUM(Quantity)
	AVG(Price)
	UNION ALL
============================================================================*/
-- Total Sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- How many items sold?
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales

-- Average selling price
SELECT AVG(price) AS avg_price FROM gold.fact_sales

-- Total orders
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales --> Check for duplicates

-- Total number of products
SELECT COUNT(product_key) AS total_products FROM gold.dim_products
SELECT COUNT(DISTINCT product_key) AS total_products from gold.dim_products --> Check for duplicates

-- Total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

-- Total number of customers that have placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.dim_customers
----------------------------------------------------------------------------
-- Generate a summary of key metrics
SELECT 'Total Sales' as measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL --> Add coloumn
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) AS avg_price FROM gold.fact_sales
UNION ALL
SELECT 'Total No. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total No. Products', COUNT(product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total No. Customers', COUNT(customer_key) FROM gold.dim_customers

/*============================================================================
(5) Magnitude Analysis
----------------------
WHAT? Compare the measure of values by categories

WHY? Understand the categories

HOW? Aggregation:
	AVG
	LEFT JOIN
	GROUP BY
	ORDER BY
============================================================================*/
-- Find total customers by counters
SELECT
country,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Find by gender
SELECT
gender,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Average costs in each category
SELECT
category,
AVG(cost) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC

-- Total revenue generated for each category
SELECT 
*
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p	--> Fact table LEFT join the dimensions
ON p.product_key = f.product_key

SELECT
f.sales_amount,
p.category
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.category

SELECT							--> Now, aggregate and Execute
p.category,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

-- Total revenue generated by each customer
SELECT							--> Fact table LEFT join the dimensions
*
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key

SELECT							--> Now, aggregate and Execute (Result: High cardinality dimension - large number of unique values)
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

-- Distribution of sold items across countries
SELECT							--> Now, aggregate and Execute. (Result: Low cardinality dimension - low number of unique values)
c.country,
SUM(f.sales_amount) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.country
ORDER BY total_sold_items DESC

/*============================================================================
(6) Ranking Analysis
--------------------
WHAT? Order values of dimensions by measure, e.g. Rank [Countries] by [Total Sales]

WHY? Identify top and bottom performers

HOW? Rank [DIMENSION] by [MEASURE]:
	RANK()
	DENSE_RANK()
	ROW_NUMBER()
============================================================================*/
-- Which 5 products generate the highest revenue?
SELECT TOP 5	
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- The 5 customers with fewest orders placed
SELECT TOP 5
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_orders

-- Top 5 customers who have generated the highest revenue
SELECT TOP 5
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

	--- Alternative method for complex demands, i.e. mix & match columns
SELECT *
FROM (
SELECT
	p.product_name,
	SUM(f.sales_amount) total_revenue,
	ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name)s
WHERE rank_products <= 5

-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5	
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue
	
	--- By subcategory
SELECT TOP 5	
p.subcategory,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue

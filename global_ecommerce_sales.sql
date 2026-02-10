/* 
=======================================================
Patterns Behind Purchases: Analyzing Global E-Commerce
=======================================================
Purpose:

This report uses SQL to analyze sales performance across time, product categories, and customer behavior.
The goal is to uncover revenue drivers, peak months, and top-performing products to support business decision-making.

Dataset Overview:

	Table: sales_data

	Key Columns Used:
	- Order_ID
	- Country
	- Category
	- Unit_Price
	- Quantity
	- Order_Date
	- Total_Amount

Hightlights:
	1. Analyzed overall sales performance, calculating total orders, total units sold, total revenue, and average order value (AOV).
	2. Identified top-performing countries and product categories, revealing key geographic markets and primary revenue drivers.
	3. Uncovered seasonality patterns through monthly revenue trends and compared January vs. July demand to highlight shifting customer preferences.
	4. Evaluated unit economics by category (price vs. volume) to explain whether revenue growth was driven by high pricing power or high sales volume.
	5. Assessed revenue concentration and high-value transactions, highlighting reliance on top countries and identifying large, high-impact orders.
=======================================================
*/

USE ecommerce_data;
SELECT * FROM sales_data;

-- Overall Sales Performance

SELECT 
	COUNT(DISTINCT Order_ID) AS total_orders,
	SUM(Quantity) AS total_units_sold,
	SUM(Total_Amount) AS total_sales
FROM sales_data;

/*------------------------------------------------------
Insight: 
	- This establishes the business baseline: overall demand (orders/units) and monetization (sales).
	- If units sold is high but sales is not, it suggests lower-priced products or heavy discounting.
	- If orders are high but units sold per order is low, customers may be buying single-item baskets (bundle opportunity).
------------------------------------------------------*/


-- Total Revenue by Country

SELECT Country,
	COUNT(DISTINCT Order_ID) AS orders,
    SUM(Total_Amount) AS revenue
FROM sales_data
GROUP BY Country
ORDER BY revenue DESC;

/*------------------------------------------------------
Insights:
	- Revenue is likely concentrated in a few countries (top markets).
	- Compare revenue vs orders:
		High revenue + low orders = high ticket size market
		High orders + lower revenue = price-sensitive market
	- This helps decide where to focus marketing budget, localization, and inventory.
------------------------------------------------------*/

-- Revenue by Product Category

SELECT Category,
	SUM(Quantity) AS units_sold,
    SUM(Total_Amount) AS revenue
FROM sales_data
GROUP BY Category
ORDER BY revenue DESC;

/*------------------------------------------------------
Insights: 
	- This identifies revenue drivers and which categories matter most.
	- If a category has high revenue but low units, it’s likely premium-priced.
	- If a category has high units but lower revenue, it’s likely volume-driven/low price.
------------------------------------------------------*/


-- Average Order Value

SELECT 
	ROUND(AVG(Total_Amount),2) AS avg_order
FROM sales_data;

/*------------------------------------------------------
The average order value (AOV) provides a clear benchmark for pricing and upsell strategies—any increase in AOV would have a direct, compounding impact on total revenue without needing additional customers.
------------------------------------------------------*/

WITH order_totals AS (
	SELECT Order_ID,
    SUM(Total_Amount) AS order_value,
    SUM(Quantity) AS total_units
FROM sales_data
GROUP BY Order_ID
)
SELECT
	CASE
		WHEN order_value < 50 THEN '< $50'
		WHEN order_value < 100 THEN '$50-$99'
		WHEN order_value < 250 THEN '$100-$249'
		WHEN order_value < 500 THEN '$250-$499'
		ELSE '$500+'
	END AS order_value_bucket,
    COUNT(*) AS orders,
    ROUND(AVG(order_value), 2) AS avg_order_value
FROM order_totals
GROUP BY order_value_bucket
ORDER BY MIN(order_value);

/*------------------------------------------------------
The majority of orders exceed $500, indicating a transaction model driven by high-value purchases rather than frequent small orders. This suggests the business operates closer to a bulk or enterprise-oriented sales model, where revenue is sensitive to changes in large-order behavior.
------------------------------------------------------*/

-- Monthly Revenue Trend 
SELECT
	DATE_FORMAT(STR_TO_DATE(Order_Date, '%m/%d/%Y'), '%Y-%m') AS order_month,
    SUM(Total_Amount) AS monthly_revenue
FROM sales_data
GROUP BY order_month
ORDER BY monthly_revenue;

-- What products were bought the most in July ?
SELECT Category,
	SUM(Quantity) AS total_units_sold
FROM sales_data
WHERE DATE_FORMAT(STR_TO_DATE(Order_Date, '%m/%d/%Y'), '%Y-%m') = '2025-07'
GROUP BY Category
ORDER BY total_units_sold DESC;

--  What products were bought the most in January ?
SELECT Category,
	SUM(Quantity) AS total_units_sold
FROM sales_data
WHERE DATE_FORMAT(STR_TO_DATE(Order_Date, '%m/%d/%Y'), '%Y-%m') = '2025-01'
GROUP BY Category
ORDER BY total_units_sold DESC;

/*------------------------------------------------------
Monthly revenue trends reveal clear seasonality, with demand peaking in mid-year (July) and in early-year months (January). The contrast between January and July category demand shows that customer purchasing behavior changes by season, indicating that promotions, inventory planning, and marketing campaigns should be adjusted dynamically rather than applied uniformly year-round.
------------------------------------------------------*/

-- Unit Economy: Price vs. Volume
SELECT Category,
	ROUND(AVG(Unit_Price), 2) AS avg_unit_price,
    SUM(Quantity) AS total_units,
    SUM(Total_Amount) AS revenue
FROM sales_data
GROUP BY Category
ORDER BY revenue DESC;

/*------------------------------------------------------
Insight:
 - Distinguishes categories that win by:
		Pricing power (high avg price, lower units)
		Volume (lower avg price, very high units)
------------------------------------------------------*/

-- TOP 10 Orders by Revenue
SELECT 
	Order_ID,
    Country,
    Category,
    Total_Amount
FROM sales_data
ORDER BY Total_Amount DESC
LIMIT 10;

-- TOP Products Bought in USA
SELECT 
    Country,
    Category,
    SUM(Total_amount) AS total_revenue
FROM sales_data
WHERE Country = 'USA'
GROUP BY Category
ORDER BY total_revenue DESC;

-- Top Products Bought in China
SELECT 
    Country,
    Category,
    SUM(Total_amount) AS total_revenue
FROM sales_data
WHERE Country = 'China'
GROUP BY Category
ORDER BY total_revenue DESC;

-- Top Products Bought in India
SELECT 
    Country,
    Category,
    SUM(Total_amount) AS total_revenue
FROM sales_data
WHERE Country = 'India'
GROUP BY Category
ORDER BY total_revenue DESC;

/*------------------------------------------------------
The United States, China, and India each show different top-purchased product categories, reflecting variations in consumer preferences, spending behavior, and market dynamics across regions. These three countries were analyzed specifically because of their large populations and significant impact on overall demand, making them critical markets for understanding revenue distribution and product performance. Comparing their top-bought products helps highlight why a one-size-fits-all strategy is ineffective and underscores the importance of tailoring product and marketing strategies to each country’s market characteristics.
------------------------------------------------------*/

-- Revenue Concentration (by Country)
SELECT Country,
	SUM(Total_Amount)/(SELECT SUM(Total_Amount) FROM sales_data)*100 AS revenue_share
FROM sales_data
GROUP BY Country
ORDER BY revenue_share DESC;

/*------------------------------------------------------
Insight:
	- Measures market concentration risk.
	- If the top 1–3 countries account for a large share, business performance is sensitive to those markets (currency, regulations, competition, logistics).
	- Strong justification for diversification or deeper investment in top markets.
------------------------------------------------------*/
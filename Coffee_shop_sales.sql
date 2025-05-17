create database Coffe_shop_sales_database
select *from coffee_shop_sales
describe coffee_shop_sales

update coffee_shop_sales
set transaction_date = STR_TO_DATE(transaction_date, '%Y-%m-%d'); -- CONVERT DATE (transaction_date) COLUMN TO PROPER DATE FORMAT 


alter table coffee_shop_sales -- ALTER DATE (transaction_date) COLUMN TO DATE DATA TYPE
modify column transaction_date date;

describe coffee_shop_sales -- DATA TYPES OF DIFFERENT COLUMNS

update coffee_shop_sales
set transaction_time = str_to_date(transaction_time,'%H:%i:%s'); -- CONVERT TIME (transaction_time)  COLUMN TO PROPER DATE FORMAT
alter table coffee_shop_sales -- ALTER TIME (transaction_time) COLUMN TO DATE DATA TYPE
modify column transaction_time time;

describe coffee_shop_sales -- DATA TYPES OF DIFFERENT COLUMNS

alter table coffee_shop_sales -- CHANGE COLUMN NAME `ï»¿transaction_id` to transaction_id
change column ï»¿transaction_id transaction_id int; 
select *from coffee_shop_sales
describe coffee_shop_sales

select round(sum(unit_price * transaction_qty)) as total_sales 
from coffee_shop_sales -- total sales for each respective months
where
month(transaction_date) = 3;  -- may month

-- selected month / CM - may = 5
-- PM - April = 4
-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
select
 month(transaction_date) as month, -- number of month
 round(sum(unit_price * transaction_qty)) as total_sales, -- Total sales column
  (sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty),1) -- Month sales difference
  over (order by month(transaction_date))) / lag(sum(unit_price * transaction_qty),1 ) -- Division by PM sales
  over (order by month(transaction_date)) * 100 as mom_increase_percentage -- Percentage and mom is month on month
  from
  coffee_shop_sales
  where
  month(transaction_date) in (4,5) -- for months of April(PM) and May(CM)
  group by
  month(transaction_date)
  order by
  month(transaction_date);
-- Explaination
-- SELECT clause:
-- 	MONTH(transaction_date) AS month: Extracts the month from the transaction_date column and renames it as month.alter
-- •	ROUND(SUM(unit_price * transaction_qty)) AS total_sales: Calculates the total sales by multiplying unit_price and transaction_qty, then sums the result for each month. The ROUND function rounds the result to the nearest integer.
-- •	(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage with the functions used:
-- o	SUM(unit_price * transaction_qty): This calculates the total sales for the current month. It multiplies the unit_price by the transaction_qty for each transaction and then sums up these values.
-- o	LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date)): This function retrieves the value of the total sales for the previous month. It uses the LAG window function to get the value of the SUM(unit_price * transaction_qty) from the previous row (previous month) ordered by the transaction_date.
-- o	(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date))): This part calculates the difference between the total sales of the current month and the total sales of the previous month.
-- o	LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date)): This function retrieves the value of the total sales for the previous month again. It's used in the denominator to calculate the percentage increase.
-- o	(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date)): This calculates the ratio of the difference in sales between the current and previous months to the total sales of the previous month. It represents the percentage increase or decrease in sales compared to the previous month.
-- o	100: This part multiplies the ratio by 100 to convert it to a percentage.
-- •	FROM clause:
-- coffee_shop_sales: Specifies the table from which data is being selected.
-- •	WHERE clause:
-- MONTH(transaction_date) IN (4, 5): Filters the data to include only transactions from April and May.
-- •	GROUP BY clause:
-- MONTH(transaction_date): Groups the results by month.
-- •	ORDER BY clause:
-- MONTH(transaction_date): Orders the results by month.

-- TOTAL ORDERS
select count(transaction_id) as total_orders
from coffee_shop_sales
where
month(transaction_date) = 5 -- may month

-- TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH
select 
month(transaction_date) as month,
round(count(transaction_id)) as total_orders,
(count(transaction_id) - lag( count(transaction_id),1)
over (order by month (transaction_date))) / lag(count(transaction_id) , 1)
over(order by month(transaction_date)) * 100 as mom_increase_percentage
from
coffee_shop_sales
where
month(transaction_date) in (4,5)
group by 
month(transaction_date)
order by
month(transaction_date)

-- TOTAL QUANTITY SOLD
select sum(transaction_qty) as Total_quantity_sold
from coffee_shop_sales
where
month(transaction_date) = 5 -- May Month

-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    
    -- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
    SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18'; -- For 18 May 2023
    
    
    -- If you want to get exact Rounded off values then use below query to get the result
    SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18'; -- For 18 May 2023
    
    
    -- SALES TREND OVER PERIOD
    SELECT AVG(total_sales) AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffee_shop_sales
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;
-- Query Explanation:
-- •	This inner subquery calculates the total sales (unit_price * transaction_qty) for each date in May. It filters the data to include only transactions that occurred in May by using the MONTH() function to extract the month from the transaction_date column and filtering for May (month number 5).
-- •	The GROUP BY clause groups the data by transaction_date, ensuring that the total sales are aggregated for each individual date in May.
-- •	The outer query calculates the average of the total sales over all dates in May. It references the result of the inner subquery as a derived table named internal_query.
-- •	The AVG() function calculates the average of the total_sales column from the derived table, giving us the average sales for May.


-- DAILY SALES FOR MONTH SELECTED
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);


-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
   -- SALES BY WEEKDAY / WEEKEND:
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;

-- SALES BY STORE LOCATION
SELECT 
	store_location,
	SUM(unit_price * transaction_qty) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC

-- SALES BY PRODUCT CATEGORY
SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC


-- SALES BY PRODUCTS (TOP 10)
SELECT 
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10

-- SALES BY DAY | HOUR
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)
    
    -- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;


-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);





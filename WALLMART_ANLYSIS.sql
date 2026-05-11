/*========================================================
    DATABASE SETUP
========================================================*/

CREATE DATABASE STORE_ANALYSE;
GO

USE STORE_ANALYSE;
GO


/*========================================================
    TABLE CREATION
========================================================*/

CREATE TABLE store (
    transaction_id     VARCHAR(15),
    customer_id        VARCHAR(15),
    customer_name      VARCHAR(100),   -- Increased to avoid truncation
    customer_age       INT,
    gender             VARCHAR(10),
    product_id         VARCHAR(15),
    product_name       VARCHAR(50),
    product_category   VARCHAR(50),
    quantity           INT,
    price              DECIMAL(10,2), -- Better for monetary values
    payment_mode       VARCHAR(20),
    purchase_date      DATE,
    time_of_purchase   TIME,
    status             VARCHAR(15)
);

GO


/*========================================================
    DATA IMPORT
========================================================*/

SET DATEFORMAT dmy;

BULK INSERT store
FROM 'D:\Data Science\sql db\sql-data-analytics-project\datasets\Other\sales_store.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

GO


/*========================================================
                          DATA CLEANING
        ========================================================*/


/*--------------------------------------------------------
    1. REMOVE DUPLICATES
--------------------------------------------------------*/

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id
               ORDER BY transaction_id
           ) AS row_num
    FROM store
)
DELETE FROM duplicate_cte
WHERE row_num > 1;

GO


/*--------------------------------------------------------
    2. STANDARDIZE COLUMN NAMES
--------------------------------------------------------*/

EXEC sp_rename 'store.quantiy', 'quantity', 'COLUMN';
EXEC sp_rename 'store.prce', 'price', 'COLUMN';

GO

SELECT * FROM store

/*--------------------------------------------------------
    3. CHECK DATA TYPES
--------------------------------------------------------*/

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'store';

GO


/*--------------------------------------------------------
    4. NULL VALUE ANALYSIS
--------------------------------------------------------*/

DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = STRING_AGG(
'
SELECT
    ''' + COLUMN_NAME + ''' AS column_name,
    COUNT(*) AS null_count
FROM store
WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL',
'
UNION ALL
')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'store';

EXEC sp_executesql @sql;

GO


/*--------------------------------------------------------
    5. REMOVE INVALID RECORDS
--------------------------------------------------------*/

-- Transaction records without transaction_id are unusable
DELETE FROM store
WHERE transaction_id IS NULL;

GO


/*--------------------------------------------------------
    6. FIX MISSING CUSTOMER IDS
--------------------------------------------------------*/

UPDATE store
SET customer_id = 'CUST9494'
WHERE transaction_id = 'TXN977900'
  AND customer_id IS NULL;


UPDATE store
SET customer_id = 'CUST1401'
WHERE transaction_id = 'TXN985663'
  AND customer_id IS NULL;

GO


/*--------------------------------------------------------
    7. FIX MISSING CUSTOMER DETAILS
--------------------------------------------------------*/

UPDATE store
SET
    customer_name = 'Mahika Saini',
    customer_age  = 35,
    gender        = 'Male'
WHERE customer_id = 'CUST1003'
  AND (
        customer_name IS NULL OR
        customer_age IS NULL OR
        gender IS NULL
      );

GO

SELECT * FROM STORE


/*--------------------------------------------------------
    8. STANDARDIZE GENDER VALUES
--------------------------------------------------------*/

UPDATE store
SET gender =
    CASE
        WHEN gender IN ('F', 'Female', 'FEMALE') THEN 'FEMALE'
        WHEN gender IN ('M', 'Male', 'MALE') THEN 'MALE'
        ELSE gender
    END;

GO


/*--------------------------------------------------------
    9. STANDARDIZE PAYMENT MODES
--------------------------------------------------------*/

UPDATE store
SET payment_mode =
    CASE
        WHEN payment_mode = 'CC' THEN 'Credit Card'
        ELSE payment_mode
    END;

GO


/*--------------------------------------------------------
    10. FINAL DATA CHECK
--------------------------------------------------------*/

SELECT *
FROM store;

GO



/*-- ****************************************************************************************** --
                                BUSINESS INSIGHTS ANALYSIS
  -- ****************************************************************************************** --*/


/*--------------------------------------------------------
    Q1. TOP 5 BEST-SELLING PRODUCTS BY QUANTITY
--------------------------------------------------------*/

SELECT TOP 5
    product_name,
    SUM(quantity) AS total_quantity_sold
FROM store
WHERE status = 'DELIVERED'
GROUP BY product_name
ORDER BY total_quantity_sold DESC;

-- BUSINESS PROBLEM:
-- The business does not know which products are in highest demand.

-- BUSINESS IMPACT:
-- Helps prioritize inventory, avoid stock shortages,
-- and improve sales through targeted promotions.



/*--------------------------------------------------------
    Q2. MOST FREQUENTLY CANCELLED PRODUCTS
--------------------------------------------------------*/

SELECT TOP 10
    product_name,
    COUNT(*) AS total_cancellations
FROM store
WHERE status = 'CANCELLED'
GROUP BY product_name
ORDER BY total_cancellations DESC;

-- BUSINESS PROBLEM:
    -- Frequent cancellations negatively affect revenue and customer trust.

-- BUSINESS IMPACT:
    -- Helps identify low-performing or problematic products
    -- that may require quality improvements or removal.



/*--------------------------------------------------------
    Q3. PEAK PURCHASE TIME OF DAY
--------------------------------------------------------*/

WITH purchase_periods AS (
    SELECT
        CASE
            WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 0 AND 5 THEN 'Night'
            WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS time_of_day
    FROM store
)

SELECT
    time_of_day,
    COUNT(*) AS total_orders
FROM purchase_periods
GROUP BY time_of_day
ORDER BY total_orders DESC;

-- BUSINESS PROBLEM:
    -- The business lacks visibility into peak shopping hours.

-- BUSINESS IMPACT:
    -- Supports staffing optimization, marketing schedules,
    -- and better infrastructure planning during peak demand.



/*--------------------------------------------------------
    Q4. TOP 5 HIGHEST-SPENDING CUSTOMERS
--------------------------------------------------------*/

SELECT TOP 5
    customer_name,
    SUM(price * quantity) AS total_sales,
    FORMAT(SUM(price * quantity), 'C0', 'en-IN') AS formatted_sales
FROM store
GROUP BY customer_name
ORDER BY total_sales DESC;

-- BUSINESS PROBLEM:
    --  The business cannot easily identify high-value customers.

-- BUSINESS IMPACT:
    -- Enables loyalty rewards, personalized marketing,
    -- and stronger customer retention strategies.



/*--------------------------------------------------------
    Q5. PRODUCT CATEGORY WITH HIGHEST REVENUE
--------------------------------------------------------*/

SELECT
    product_category,
    SUM(quantity * price) AS total_revenue
FROM store
GROUP BY product_category
ORDER BY total_revenue DESC;

-- BUSINESS PROBLEM:
    -- The business does not know which categories drive maximum revenue.

-- BUSINESS IMPACT:
    -- Helps allocate inventory, marketing budgets,
    -- and strategic investments toward profitable categories.



/*--------------------------------------------------------
    Q6. TOP PRODUCTS FROM HIGH-REVENUE CATEGORIES
--------------------------------------------------------*/

SELECT
    product_category,
    product_name,
    SUM(quantity * price) AS total_revenue,
    FORMAT(SUM(quantity * price), 'C0', 'en-IN') AS formatted_revenue
FROM store
WHERE product_category IN ('Accessories', 'Clothing')
GROUP BY
    product_category,
    product_name
ORDER BY
    product_category,
    total_revenue DESC;

-- BUSINESS PROBLEM:
    -- The business wants to identify the strongest products
    -- within top-performing categories.

-- BUSINESS IMPACT:
    -- Helps improve product strategy, promotions,
    -- and inventory planning for high-demand items.



/*--------------------------------------------------------
    Q7. RETURN & CANCELLATION RATE BY CATEGORY
--------------------------------------------------------*/

SELECT
    product_category,

    COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) AS total_cancelled,

    COUNT(CASE WHEN status = 'RETURNED' THEN 1 END) AS total_returned,

    ROUND(
        COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) * 100.0
        / COUNT(*),
        2
    ) AS cancellation_rate_pct,

    ROUND(
        COUNT(CASE WHEN status = 'RETURNED' THEN 1 END) * 100.0
        / COUNT(*),
        2
    ) AS return_rate_pct

FROM store
GROUP BY product_category
ORDER BY cancellation_rate_pct DESC;

-- BUSINESS PROBLEM:
    -- The business cannot easily track dissatisfaction trends
    -- across product categories.

-- BUSINESS IMPACT:
    -- Helps identify quality issues, inaccurate product expectations,
    -- or logistics problems causing returns and cancellations.



/*--------------------------------------------------------
    Q8. MOST PREFERRED PAYMENT MODE
--------------------------------------------------------*/

SELECT
    payment_mode,
    COUNT(*) AS total_usage
FROM store
GROUP BY payment_mode
ORDER BY total_usage DESC;

-- BUSINESS PROBLEM:
    -- The business lacks insight into customer payment preferences.

-- BUSINESS IMPACT:
    -- Helps optimize payment systems and prioritize
    -- the most widely used payment methods.



/*--------------------------------------------------------
    Q9. AGE GROUP VS PURCHASING BEHAVIOR
--------------------------------------------------------*/

WITH customer_segments AS (
    SELECT
        CASE
            WHEN customer_age >= 50 THEN '50+'
            WHEN customer_age BETWEEN 30 AND 49 THEN '30-49'
            WHEN customer_age BETWEEN 20 AND 29 THEN '20-29'
            ELSE 'Under 20'
        END AS age_group,

        price * quantity AS sales
    FROM store
)

SELECT
    age_group,
    SUM(sales) AS total_revenue,
    FORMAT(SUM(sales), 'C0', 'en-IN') AS formatted_revenue
FROM customer_segments
GROUP BY age_group
ORDER BY total_revenue DESC;

-- BUSINESS PROBLEM:
    -- The business does not understand purchasing behavior
    -- across different age groups.

-- BUSINESS IMPACT:
    -- Supports demographic-based marketing campaigns
    -- and personalized product recommendations.



/*--------------------------------------------------------
    Q10. MONTHLY SALES TREND
--------------------------------------------------------*/

WITH monthly_sales AS (
    SELECT
        YEAR(purchase_date) AS sales_year,
        MONTH(purchase_date) AS sales_month,
        DATENAME(MONTH, purchase_date) AS month_name,
        price * quantity AS sales
    FROM store
)

SELECT
    sales_year,
    month_name,
    SUM(sales) AS monthly_revenue,
    FORMAT(SUM(sales), 'C0', 'en-IN') AS formatted_revenue
FROM monthly_sales
GROUP BY
    sales_year,
    sales_month,
    month_name
ORDER BY
    sales_year,
    sales_month;

-- BUSINESS PROBLEM:
    -- Sales fluctuations and seasonal patterns are not clearly visible.

-- BUSINESS IMPACT:
    -- Helps forecast demand, manage inventory,
    -- and plan seasonal marketing campaigns.



/*--------------------------------------------------------
    Q11. GENDER-BASED PRODUCT PREFERENCES
--------------------------------------------------------*/

SELECT
    gender,
    product_category,
    COUNT(*) AS total_purchases
FROM store
GROUP BY
    gender,
    product_category
ORDER BY
    gender,
    total_purchases DESC;

-- BUSINESS PROBLEM:
    -- The business lacks understanding of gender-specific
    -- purchasing preferences.

-- BUSINESS IMPACT:
    -- Enables targeted advertising, audience segmentation,
    -- and personalized product recommendations.

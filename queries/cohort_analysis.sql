WITH customer_purchases AS (
   
    SELECT 
        customer_id,
        order_date,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) as purchase_number
    FROM orders
),
cohort_map AS (
    
    SELECT 
        customer_id,
        DATE_TRUNC('month', order_date) AS cohort_month
    FROM customer_purchases
    WHERE purchase_number = 1
),
retention_calc AS (
    
    SELECT 
        c.cohort_month,
        o.customer_id,
        o.order_date,
        (o.order_date - c.cohort_month) AS days_since_first
    FROM orders o
    JOIN cohort_map c ON o.customer_id = c.customer_id
)
SELECT 
    TO_CHAR(cohort_month, 'YYYY-MM') AS cohort,
    COUNT(DISTINCT customer_id) AS cohort_size,
   
    ROUND(COUNT(DISTINCT CASE WHEN days_since_first > INTERVAL '0 days' AND days_since_first <= INTERVAL '30 days' THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) AS pct_repeat_30d,
    ROUND(COUNT(DISTINCT CASE WHEN days_since_first > INTERVAL '30 days' AND days_since_first <= INTERVAL '60 days' THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) AS pct_repeat_60d,
    ROUND(COUNT(DISTINCT CASE WHEN days_since_first > INTERVAL '60 days' AND days_since_first <= INTERVAL '90 days' THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) AS pct_repeat_90d
FROM retention_calc
GROUP BY 1
ORDER BY 1;
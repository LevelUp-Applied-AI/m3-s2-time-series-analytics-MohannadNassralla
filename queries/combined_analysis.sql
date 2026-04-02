-- Query A: حصة الفئة من الإيرادات مع مقارنة نموها الشهري
WITH cat_monthly AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS month,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY 1, 2
)
SELECT 
    TO_CHAR(month, 'YYYY-MM') AS month,
    category,
    revenue,
    -- حصة الفئة من إجمالي إيرادات الشهر (SUM Window)
    ROUND(revenue / SUM(revenue) OVER(PARTITION BY month) * 100, 2) AS cat_share_pct,
    -- نمو الفئة مقارنة بالشهر السابق (LAG)
    ROUND((revenue - LAG(revenue) OVER(PARTITION BY category ORDER BY month)) / 
          NULLIF(LAG(revenue) OVER(PARTITION BY category ORDER BY month), 0) * 100, 2) AS cat_growth_pct
FROM cat_monthly
ORDER BY month, revenue DESC;

-- Query B: إيرادات الشرائح (Segments) مع الإجمالي التراكمي ونسبة النمو
WITH segment_monthly AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS month,
        c.segment,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY 1, 2
)
SELECT 
    TO_CHAR(month, 'YYYY-MM') AS month,
    segment,
    revenue,
    -- الإجمالي التراكمي لكل شريحة (Running Total)
    SUM(revenue) OVER(PARTITION BY segment ORDER BY month) AS running_total_revenue,
    -- نمو الشريحة MoM
    ROUND((revenue - LAG(revenue) OVER(PARTITION BY segment ORDER BY month)) / 
          NULLIF(LAG(revenue) OVER(PARTITION BY segment ORDER BY month), 0) * 100, 2) AS segment_growth_pct
FROM segment_monthly
ORDER BY month, segment;
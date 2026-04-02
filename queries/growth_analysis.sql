WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        COUNT(DISTINCT o.order_id) AS order_volume
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1
),
growth_stats AS (
    SELECT 
        month,
        revenue,
        order_volume,
        LAG(revenue) OVER(ORDER BY month) AS prev_month_revenue,
        LAG(order_volume) OVER(ORDER BY month) AS prev_month_volume,
      
        LAG(revenue, 3) OVER(ORDER BY month) AS prev_quarter_revenue
    FROM monthly_revenue
)
SELECT 
    TO_CHAR(month, 'YYYY-MM') AS month,
    revenue,
    ROUND((revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100, 2) AS mom_revenue_growth_pct,
    order_volume,
    ROUND((order_volume - prev_month_volume) / NULLIF(prev_month_volume, 0) * 100, 2) AS mom_volume_growth_pct,
    ROUND((revenue - prev_quarter_revenue) / NULLIF(prev_quarter_revenue, 0) * 100, 2) AS qoq_revenue_growth_pct,
    ROUND(revenue / NULLIF(order_volume, 0), 2) AS avg_order_value -- يساعد في معرفة سبب النمو
FROM growth_stats
ORDER BY month;
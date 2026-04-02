WITH daily_metrics AS (
    SELECT 
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT 
    order_date,
    revenue AS raw_daily_revenue,
    -- متوسط متحرك لـ 7 أيام للإيرادات
    ROUND(AVG(revenue) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_rev_7d,
    -- متوسط متحرك لـ 30 يوم للإيرادات
    ROUND(AVG(revenue) OVER(ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) AS moving_avg_rev_30d,
    -- متوسط متحرك لـ 7 أيام لعدد الطلبات
    ROUND(AVG(order_count) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_orders_7d
FROM daily_metrics
ORDER BY order_date;
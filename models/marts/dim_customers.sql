{{
    config(
        materialized='table'
    )
}}

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

sales AS (
    SELECT * FROM {{ ref('int_sales_with_customers') }}
),

customer_metrics AS (
    SELECT
        customer_key,
        COUNT(DISTINCT ticket_number) AS total_transactions,
        SUM(quantity) AS total_items_purchased,
        SUM(extended_sales_price) AS total_revenue,
        AVG(extended_sales_price) AS avg_transaction_value,
        SUM(discount_amount) AS total_discounts_received,
        MIN(date_key) AS first_purchase_date,
        MAX(date_key) AS last_purchase_date
    FROM sales
    WHERE customer_key IS NOT NULL
    GROUP BY customer_key
),

final AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.email,
        c.birth_country,
        c.birth_year,
        
        COALESCE(cm.total_transactions, 0) AS total_transactions,
        COALESCE(cm.total_items_purchased, 0) AS total_items_purchased,
        COALESCE(cm.total_revenue, 0) AS total_revenue,
        COALESCE(cm.avg_transaction_value, 0) AS avg_transaction_value,
        COALESCE(cm.total_discounts_received, 0) AS total_discounts_received,
        cm.first_purchase_date,
        cm.last_purchase_date,
        
        CASE 
            WHEN cm.total_revenue > 10000 THEN 'VIP'
            WHEN cm.total_revenue > 5000 THEN 'High Value'
            WHEN cm.total_revenue > 1000 THEN 'Medium Value'
            WHEN cm.total_revenue > 0 THEN 'Low Value'
            ELSE 'New Customer'
        END AS customer_segment,
        
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM customers c
    LEFT JOIN customer_metrics cm ON c.customer_key = cm.customer_key
)

SELECT * FROM final 
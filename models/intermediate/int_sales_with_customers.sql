{{
    config(
        materialized='view'
    )
}}

WITH sales AS (
    SELECT * FROM {{ ref('stg_store_sales') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

items AS (
    SELECT * FROM {{ ref('stg_items') }}
),

joined AS (
    SELECT
        -- Sales info
        s.ticket_number,
        s.date_key,
        s.time_key,
        s.quantity,
        s.sales_price,
        s.extended_sales_price,
        s.discount_amount,
        s.net_paid,
        
        -- Customer info
        s.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.birth_country,
        c.birth_year,
        
        -- Item info
        s.item_key,
        i.item_id,
        i.item_description,
        i.brand,
        i.item_class,
        i.category,
        i.current_price,
        
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM sales s
    LEFT JOIN customers c ON s.customer_key = c.customer_key
    LEFT JOIN items i ON s.item_key = i.item_key
)

SELECT * FROM joined
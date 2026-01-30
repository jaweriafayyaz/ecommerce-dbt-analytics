{{
    config(
        materialized='table'
    )
}}

WITH sales_data AS (
    SELECT * FROM {{ ref('int_sales_with_customers') }}
),

final AS (
    SELECT
        ticket_number,
        date_key,
        time_key,
        customer_key,
        customer_id,
        first_name || ' ' || last_name AS customer_name,
        birth_country,
        birth_year,
        item_key,
        item_id,
        item_description,
        brand,
        item_class,
        category,
        quantity,
        sales_price,
        extended_sales_price,
        discount_amount,
        net_paid,
        
        -- Calculated metrics
        extended_sales_price AS revenue,
        CASE 
            WHEN discount_amount > 0 THEN 'Discounted'
            ELSE 'Full Price'
        END AS price_type,
        
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM sales_data
    WHERE extended_sales_price IS NOT NULL  -- ← Add this line
)

SELECT * FROM final
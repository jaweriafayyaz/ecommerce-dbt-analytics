WITH source AS (
    SELECT * FROM {{ source('tpcds', 'item') }}
),

renamed AS (
    SELECT
        i_item_sk AS item_key,
        i_item_id AS item_id,
        i_item_desc AS item_description,
        i_brand AS brand,
        i_class AS item_class,
        i_category AS category,
        i_current_price AS current_price,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM source
    WHERE i_item_sk IS NOT NULL
)

SELECT * FROM renamed
LIMIT 5000
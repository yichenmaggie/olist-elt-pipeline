-- Staging model for order items: one row per (order_id, order_item_id).
-- Rules: rename, cast and standardize only. No joins, no business logic.

with source as (

    select * from {{ source('olist', 'raw_order_items') }}

),

renamed as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        -- Seller's shipping deadline, cast from STRING with an explicit format.
        to_timestamp_ntz(shipping_limit_date, 'YYYY-MM-DD HH24:MI:SS') as shipping_limit_at,
        price,
        freight_value
    from source

)

select * from renamed

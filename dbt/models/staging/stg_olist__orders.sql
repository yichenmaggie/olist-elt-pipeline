-- Staging model for orders: one row per order_id.
-- Rules: rename, cast and standardize only. No joins, no business logic.

with source as (

    select * from {{ source('olist', 'raw_orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        order_status as status,
        -- Timestamps are cast from STRING with an explicit format; bad values fail loudly.
        to_timestamp_ntz(order_purchase_timestamp, 'YYYY-MM-DD HH24:MI:SS') as purchased_at,
        to_timestamp_ntz(order_approved_at, 'YYYY-MM-DD HH24:MI:SS') as approved_at,
        to_timestamp_ntz(order_delivered_carrier_date, 'YYYY-MM-DD HH24:MI:SS') as delivered_to_carrier_at,
        to_timestamp_ntz(order_delivered_customer_date, 'YYYY-MM-DD HH24:MI:SS') as delivered_to_customer_at,
        to_timestamp_ntz(order_estimated_delivery_date, 'YYYY-MM-DD HH24:MI:SS') as estimated_delivery_at
    from source

)

select * from renamed

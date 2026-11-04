-- Staging model for order payments: one row per (order_id, payment_sequential).
-- Rules: rename, cast and standardize only. No joins, no business logic.
-- Columns are already correctly typed in RAW, so this model is a thin pass-through.

with source as (

    select * from {{ source('olist', 'raw_order_payments') }}

),

renamed as (

    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    from source

)

select * from renamed

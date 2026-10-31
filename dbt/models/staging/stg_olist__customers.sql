-- Staging model for customers: one row per customer_id (one id per order in Olist).
-- Rules: rename, cast and standardize only. No joins, no business logic.


with source as (


   select * from {{ source('olist', 'raw_customers') }}


),


renamed as (


   select
       customer_id,
       customer_unique_id,
       customer_zip_code_prefix as zip_code_prefix,  -- kept as string to preserve leading zeros
       customer_city as city,
       customer_state as state
   from source


)


select * from renamed

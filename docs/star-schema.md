# Star Schema (MVP)

## Grain decisions

- `fct_order_items`: one row per order item (`order_id` + `order_item_id`).
- `fct_order_payments`: one row per payment (`order_id` + `payment_sequential`).
  Kept as a separate fact because payments are at order level. Joining them into
  `fct_order_items` would repeat the payment value on every item row and inflate sums.
- `dim_customers`: one row per real customer (`customer_unique_id`).
  In Olist, `customer_id` is generated per order, so it cannot identify a person.
- `dim_date`: one row per calendar day.

```mermaid
erDiagram
  dim_customers ||--o{ fct_order_items : customer_key
  dim_date ||--o{ fct_order_items : purchase_date_key
  dim_customers ||--o{ fct_order_payments : customer_key
  dim_date ||--o{ fct_order_payments : purchase_date_key

  fct_order_items {
    string order_id "degenerate dimension"
    int order_item_id
    string customer_key FK
    int purchase_date_key FK
    string order_status
    decimal price "measure"
    decimal freight_value "measure"
  }
  fct_order_payments {
    string order_id "degenerate dimension"
    int payment_sequential
    string customer_key FK
    int purchase_date_key FK
    string payment_type
    int payment_installments
    decimal payment_value "measure"
  }
  dim_customers {
    string customer_key PK
    string customer_unique_id
    string city
    string state
  }
  dim_date {
    int date_key PK
    date full_date
    int year
    int month
    int day_of_week
  }
```

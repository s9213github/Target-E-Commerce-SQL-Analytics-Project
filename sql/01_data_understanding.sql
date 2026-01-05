-- Data understanding queries
-- Total number of orders
SELECT COUNT(*) FROM `Target_Cs.orders`;

-- Date range of orders
SELECT 
  MIN(DATE(order_purchase_timestamp)) AS first_order,
  MAX(DATE(order_purchase_timestamp)) AS last_order
FROM `Target_Cs.orders`;

-- Number of customers by state
SELECT customer_state, COUNT(DISTINCT customer_id)
FROM `Target_Cs.customers`
GROUP BY customer_state;

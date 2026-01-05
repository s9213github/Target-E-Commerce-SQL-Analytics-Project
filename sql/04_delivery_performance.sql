# Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
--Also, calculate the difference (in days) between the estimated & actual delivery date of an order. Do this in a single query.
select order_id,date_diff(order_delivered_customer_date, order_purchase_timestamp, day) delivery_time,
date_diff(order_estimated_delivery_date,order_delivered_customer_date,day) estimated_delivery_time
from `Target_Cs.orders` ;

# Find out the top 5 states with the highest & lowest average freight value.
with freight as (
select
c.customer_state,avg(freight_value) avg_freight
from `Target_Cs.customers` c
join `Target_Cs.orders` o1
on c.customer_id = o1.customer_id
join `Target_Cs.order_items` o2
on o1.order_id = o2.order_id
group by c.customer_state)
select customer_state
from (select *,
dense_rank() over(order by avg_freight desc) max_rank,
dense_rank() over(order by avg_freight) min_rank
from freight)
where max_rank < 6 or min_rank <6;

# Find out the top 5 states with the highest & lowest average delivery time.
--approach 1
with delivery_time as (
  select c.customer_state,avg(date_diff(order_delivered_customer_date, order_purchase_timestamp,day)) avg_delivery_time
  from `Target_Cs.customers` c
  join `Target_Cs.orders` o
  on c.customer_id = o.customer_id
  group by c.customer_state
  )
  SELECT
  t.rn,
  t.customer_state AS top5_states,
  b.customer_state AS bottom5_states
FROM (
  SELECT customer_state,
         ROW_NUMBER() OVER (ORDER BY avg_delivery_time DESC) AS rn
  FROM delivery_time
) t
JOIN (
  SELECT customer_state,
         ROW_NUMBER() OVER (ORDER BY avg_delivery_time ASC) AS rn
  FROM delivery_time
) b
ON t.rn = b.rn
WHERE t.rn <= 5
ORDER BY t.rn;

---Approach 2

with delivery_time as (
  select c.customer_state,avg(date_diff(order_delivered_customer_date, order_purchase_timestamp,day)) avg_delivery_time
  from `Target_Cs.customers` c
  join `Target_Cs.orders` o
  on c.customer_id = o.customer_id
  group by c.customer_state
  ),

rank_delivery as(
  select customer_state,avg_delivery_time,
  dense_rank() over(order by avg_delivery_time desc) high_delivery_time,
  dense_rank() over(order by avg_delivery_time asc) low_deliver_time
  from delivery_time
)

SELECT
  MAX(CASE WHEN high_delivery_time <= 5 THEN customer_state END)    AS top5_states,
  MAX(CASE WHEN low_deliver_time <= 5 THEN customer_state END) AS bottom5_states
FROM rank_delivery
GROUP BY high_delivery_time, low_deliver_time
ORDER BY high_delivery_time, low_deliver_time;

# Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.
with delivery_time as
(select o.order_id,c.customer_state,
date_diff(order_delivered_customer_date, order_purchase_timestamp,day) actual_delivery_time,
date_diff(order_estimated_delivery_date,order_purchase_timestamp,day) estimated_delivery_time
from `Target_Cs.customers` c
join `Target_Cs.orders` o
on c.customer_id = o.customer_id
and order_status = 'delivered')
select customer_state,avg(actual_delivery_time) avg_actual ,
avg(estimated_delivery_time)avg_estimated,
round((avg(actual_delivery_time)- avg(estimated_delivery_time)),2) time_difference
from delivery_time
group by customer_state
having avg_actual < avg_estimated
order by time_difference
limit 5;


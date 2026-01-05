# Is there a growing trend in the no. of orders placed over the past years?
with yearly_orders as (
select *,extract(year from order_purchase_timestamp) as order_year
from `Target_Cs.orders`)
select order_year, count(*) no_of_orders
from yearly_orders
group by 1
order by 1;

# Can we see some kind of monthly seasonality in terms of the no. of orders being placed?

with seasonality as (
select *,extract(year from order_purchase_timestamp) as order_year,
extract(month from order_purchase_timestamp) as order_month
from `Target_Cs.orders`)
select order_year,order_month,count(*) no_of_orders
from seasonality 
group by 1,2
order by 1,2;

# During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
with order_duration as(
select customer_id,order_id,
extract(time from order_purchase_timestamp) as order_time
from `Target_Cs.orders`),
time_flag as (
select *, 
case 
when order_time between '00:00:00' and '06:59:59' then 'Dawn' 
when order_time between '07:00:00' and '12:59:59' then 'Morning'
when order_time between '13:00:00' and '18:59:59' then 'Afternoon' 
else 'Night' 
end duration_flag
from order_duration)
select duration_flag, count(*) as no_of_orders
from time_flag
group by 1;

# Get the month on month no. of orders placed in each state.
with MOM_orders as (
select c.customer_id,c.customer_state,o.order_id,
extract(month from order_purchase_timestamp) as order_year,
extract(month from order_purchase_timestamp) as order_month
from `Target_Cs.customers` c
join `Target_Cs.orders` o
on c.customer_id = o.customer_id)
select order_year,order_month, customer_state,count(*) no_of_orders
from MOM_orders
group by 1,2,3
order by 1,2,3;

#How are the customers distributed across all the states?

select customer_state,count(distinct customer_id) no_of_unique_customers
from `Target_Cs.customers`
group by 1;

#Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).
with cost_of_orders as (
select extract(year from o.order_purchase_timestamp) order_year,
extract(month from o.order_purchase_timestamp) order_month,
sum(p.payment_value) as order_cost
from `Target_Cs.orders` o
join `Target_Cs.payments` p
on o.order_id = p.order_id
WHERE EXTRACT(YEAR  FROM o.order_purchase_timestamp) IN (2017, 2018)
AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
group by 1,2),

pct_increase as (
select c1.order_month, c1.order_cost as cost_2017,c2.order_cost as cost_2018,
  ROUND(((c2.order_cost - c1.order_cost) / c1.order_cost )* 100,2) as inc_pc
  from cost_of_orders c1
  join cost_of_orders c2
  on c1.order_month = c2.order_month 
  and c1.order_year=2017
  and c2.order_year=2018)

  select order_month, cost_2017,cost_2018,
  round((((cost_2018-cost_2017)/cost_2017)*100),2) as percent_increase
  from pct_increase
  order by order_month;

#Calculate the Total & Average value of order price for each state.

select c.customer_state,sum(p.payment_value) total_cost, avg(p.payment_value) avg_cost
from `Target_Cs.customers` c
join `Target_Cs.orders` o
on c.customer_id = o.customer_id
join `Target_Cs.payments` p
on o.order_id = p.order_id
group by c.customer_state

#Calculate the Total & Average value of order freight for each state.
select c.customer_state,sum(o2.freight_value) total_freight,
avg(o2.freight_value) avg_freight
from `Target_Cs.customers` c
join `Target_Cs.orders` o1
on c.customer_id = o1.customer_id
join `Target_Cs.order_items` o2
on o1.order_id = o2.order_id
group by c.customer_state;






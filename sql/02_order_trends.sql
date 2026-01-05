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

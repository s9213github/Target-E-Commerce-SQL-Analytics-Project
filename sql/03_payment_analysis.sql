#Find the month on month no. of orders placed using different payment types.
with order_payment as
(select o.order_id,extract(year from o.order_purchase_timestamp) order_year,
extract(month from o.order_purchase_timestamp) order_month,
p.payment_type
from `Target_Cs.orders` o
join  `Target_Cs.payments` p
on o.order_id = p.order_id
)
select payment_type,order_year,order_month,count(distinct order_id) no_of_orders
from order_payment
group by 1,2,3
order by 1,2,3;

#Find the no. of orders placed on the basis of the payment installments that have been paid.
select payment_installments,count(distinct order_id) no_of_orders
from `Target_Cs.payments` 
group by payment_installments
order by 1;

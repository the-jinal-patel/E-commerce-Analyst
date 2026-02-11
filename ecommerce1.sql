create database ecommerce;
use ecommerce;
select * from customers_review_table;
SELECT * FROM Customers_table;
select * from Order_items_table;
select * from Orders_table;
select * from Payments_table;
select * from Products_table;
select * from Sellers_table;

--que1)How much total money has the platform made so far, and how has it changed over time?--


with monthly_revenue as (
    select
        year(o.order_purchase_timestamp) as order_year,
        month(o.order_purchase_timestamp) as order_month,
        sum(p.payment_value) as monthly_revenue
    from  orders_table o
    JOIN Payments_table p
        on o.order_id = p.order_id
    where o.order_status IN ('delivered', 'shipped', 'approved')
    group by
        year(o.order_purchase_timestamp),
        month(o.order_purchase_timestamp)
)
select
    order_year,
    order_month,
    monthly_revenue,
    monthly_revenue
      - LAG(monthly_revenue) over (
            order by order_year, order_month
        ) as revenue_change
from monthly_revenue
order by order_year, order_month;


/*
que2)Which product categories are the most popular, and how do their sales numbers compare 
*/


select
    pr.product_category_name,
    count(oi.order_item_id) AS total_items_sold
from  Order_items_table oi
JOIN Products_table pr
    on oi.product_id = pr.product_id
JOIN Orders_table o
    on oi.order_id = o.order_id
where o.order_status IN ('delivered', 'shipped', 'approved')
group by pr.product_category_name
order by total_items_sold desc;


--que3)What is the average amount spent per order, and how does it change depending on the product category or payment method?--



--Average Amount per Order by Payment Method--
select
    payment_type,
    avg(order_total) as avg_amount_per_order
from (
    select
        order_id,
        payment_type,
        sum(payment_value) as order_total
    from Payments_table
    group by order_id, payment_type
) t
group by payment_type
order by avg_amount_per_order desc;


select
    product_category_name,
    avg(order_total) as avg_amount_per_order
from (
    select
        oi.order_id,
        pr.product_category_name,
        sum(oi.price + oi.freight_value) as order_total
    from  order_items_table oi
    join Products_table pr
        on oi.product_id = pr.product_id
    join ORDERS_TABLE o
        on oi.order_id = o.order_id
    where o.order_status IN ('delivered', 'shipped', 'approved')
    group by
        oi.order_id,
        pr.product_category_name
) t
group by product_category_name
order by avg_amount_per_order DESC;



--que4)How many active sellers are there on the platform, and does this number go up or down over time?--


with monthly_sellers as (
    select
        year(o.order_purchase_timestamp) AS year,
        month(o.order_purchase_timestamp) AS month,
        count(DISTINCT oi.seller_id) AS active_sellers
    from Orders_table o
    JOIN Order_items_table oi
        on o.order_id = oi.order_id
    group by 
        year(o.order_purchase_timestamp),
        month(o.order_purchase_timestamp)
)
select
    year,
    month,
    active_sellers,
    active_sellers 
      - LAG(active_sellers) over (order by year, month) AS seller_change
FROM monthly_sellers
order by year, month;



--QUE5)Which products sell the most, and how have their sales changed over time?--
   

select
    year(o.order_purchase_timestamp) as year,
    month(o.order_purchase_timestamp) as month,
    oi.product_id,
    sum(oi.price) AS total_revenue
from Orders_table o
join Order_items_table oi
    on o.order_id = oi.order_id
group by
    year(o.order_purchase_timestamp),
    month(o.order_purchase_timestamp),
    oi.product_id
order by
    year, month, total_revenue desc;  





--que6)Do customer reviews and ratings help products sell more or perform better on the platform? (Check sales with higher or lower ratings and identify if any correlation is there?--


	   select
    oi.product_id,
    avg(cr.review_score * 1.0) as avg_review_score,
    count(cr.review_id) as total_reviews,
    count(*) as units_sold,
    sum(oi.price) as total_revenue
from Order_items_table oi
join Customers_review_table cr
    on oi.order_id = cr.order_id
group by oi.product_id;






select name,salary from
    rank() over (order by salary)
emp_salary;
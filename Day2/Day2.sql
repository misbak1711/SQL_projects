------------------ e-commerce analysis ------------------

-- Select Database to use --
use [e-commerce];

-- Use Cases -- 

-- 1) How many unique customers are there in the dataset?

select count(distinct(customer_id)) as Unique_Customers
from customers;


-- 2) List all the product categories along with their English translations
select p.product_category_name, t.product_category_name_english
from category_name_translation t
join products p 
on t.product_category_name= p.product_category_name;


-- 3) Find the top 5 states with the highest number of orders
select top 5 c.customer_state, count(o.order_id) as Total_Orders
from orders o 
join customers c 
on o.customer_id = c.customer_id
group by c.customer_state
order by Total_Orders Desc;


-- 4) Calculate the total revenue generated
select round(sum(price),2) from order_items;


-- 5) Find the product with the highest revenue.
select top 1 p.product_id, 
			c.product_category_name_english, 
			round(sum(o.price),2) as Revenue
from order_items o
join products p on o.product_id = p.product_id
join category_name_translation c on p.product_category_name = c.product_category_name
group by p.product_id, c.product_category_name_english
order by Revenue desc;


-- 6) Calculate the average delivery time (in days) for each state
select c.customer_state, avg(datediff(d, order_purchase_timestamp, order_delivered_customer_date)) as Delivery_time
from orders o 
join customers c 
on o.customer_id = c.customer_id
where o.order_delivered_customer_date IS NOT NULL
AND o.order_purchase_timestamp IS NOT NULL
AND o.order_delivered_customer_date > o.order_purchase_timestamp
group by c.customer_state
order by Delivery_time;


-- 7) Create a stored procedure to fetch customer orders based on their customer_id
CREATE PROCEDURE GetCustomerOrders
@CustomerId NVARCHAR(50)
AS
BEGIN
    SELECT *
    FROM orders
    WHERE customer_id = @CustomerId;
END;

EXEC GetCustomerOrders @CustomerId = '"703a839a6717be196b82ad74d103c42b"';


-- 8) Find the top 5 most reviewed products along with their average review score
select top 5 o.product_id, count(r.review_id) as Total_reviews, avg(r.review_score) as Average_Score
from order_reviews r  
join order_items o on r.order_id = o.order_id
group by o.product_id
order by Total_reviews desc;


-- 9) Create a trigger that updates a log table whenever a new review is added
CREATE TABLE review_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    review_id NVARCHAR(50),
    log_time DATETIME DEFAULT GETDATE()
);

Create Trigger LogNewReview
on order_reviews
AFTER INSERT
AS
BEGIN
    INSERT INTO review_log (review_id)
    SELECT review_id
    FROM inserted;
END;

-- Let's check trigger execution
insert into order_reviews(review_id, order_id, review_score)
values ('1', 'a2a1ed735f0637ffdecf88eefa01399d', 4.5)

select * from review_log;


-- 10) Create a trigger to ensure that no negative payment values can be inserted into the olist_order_payments_dataset table.


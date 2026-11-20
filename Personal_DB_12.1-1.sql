use websited_nevaeh;

-- Welcome to my online merch shop logs and staff

-- my 5 tables 
drop table if exists order_items;
drop table if exists orders;
drop table if exists products; 
drop table if exists loyal_customers;
drop table if exists staff;

-- the product table that hold what my shop sells and (how much we have, and how much it costs)  
create table products(
product_id int auto_increment primary key,
product_name varchar(100),
product_quantity int,
price decimal(10,2) 
);

-- My loyal customers table ( I had previously created a table dedicated to customers so thought it would be easier to name this one differently) 
create table loyal_customers(
customer_id int auto_increment primary key,
customer_name varchar(100),
email varchar(100)
);

-- This tables job is to track each order made by the customers
create table orders(
order_id int auto_increment primary key,
customer_id int, 
order_date date,
foreign key(customer_id) 
references loyal_customers(customer_id)
);


create table order_items(
order_item_id int auto_increment primary key,
order_id int,
product_id int,
price decimal(10,2),
order_status varchar(50),
foreign key(order_id) references orders(order_id),
foreign key(product_id) references products(product_id)
);


create table staff(
staff_id int auto_increment primary key,
staff_name varchar(100),
role_title varchar(50)
);

-- The 6 items my shop sells 
insert into products(product_quantity, product_name, price) value
(12, 'Funko POP', 35.00),
(6, 'Naruto Poster', 15.00),
(4, 'JJK Rug', 150.00),
(2, 'Junji-Ito Figure', 300.00),
(12, 'Luffy Figure', 250.00),
(50, 'Deku Uniform', 50.00);

-- This table holds my custromers names and thweir 'sign up' emails 
-- Real emails (struggled to bs emails so i used my friends real ones) 

insert into loyal_customers(customer_name, email) value
('Raul Fernandez', 'RaulF92@gmail.com'),
('Sarae Scott', 'saraeas08@gmail.com'),
('TaCorey Galloway','taygalloway9@gmail.com');

select  * from loyal_customers; 

insert into staff(staff_name, role_title) values
('Becca', 'Manager'),
('Nevaeh', 'figure painter'),
('Jasmine', 'Rug Maker');

select * from staff;  

-- This table is showing customer i dand the date the order was placed
insert into orders(customer_id, order_date) value
(1, '2026-04-01'),
(2, '2026-04-02'),
(1, '2026-04-03'),
(3, '2026-04-04');


-- These are past and pending orders ! 

insert into order_items(order_id, product_id, price, order_status) value
(1, 4, 300.00, 'Received'),
(1, 1, 35.00, 'In Cart - Awaiting Payment'),
(2, 5, 50.00, 'Received'),
(3, 4, 300.00, 'Received'),
(3, 3, 150.00, 'In Cart - Awaiting Payment'),
(4, 2, 30.00, 'Received');

-- 
drop view if exists product_orders;

create view product_orders as
select
products.product_name, 
order_items.price,
order_items.order_status
from products
join order_items
on products.product_id = order_items.product_id;

-- checks the view
select * from product_orders;

-- this is how the totals are being calculated

drop function if exists calculate_total_after;
DELIMITER //

create function calculate_total_after(
current_price decimal(10,2),
price decimal(10,2),
status varchar(50)
)
returns decimal(10,2)
deterministic
begin
if status = 'Received' then
    return current_price + price;
else
    return current_price;
end if;
end //
DELIMITER ;

-- TEST FUNCTION
select
product_name,
price,
calculate_total_after(price, 20, 'Received') as updated_total
from products;

--
drop procedure if exists get_orders_by_customer;
DELIMITER //

create procedure get_orders_by_customer(in cust_id int)
begin
select *
from orders
where customer_id = cust_id;
end //
DELIMITER ;

-- CALL PROCEDURE
call get_orders_by_customer(1);

-- Here i am joining 4 tables so that ti displays the full order details 
select 
loyal_customers.customer_name, -- tells me who ordered the product
products.product_name, -- what did they order
order_items.price, -- shows how much does it cost
order_items.order_status -- status of the customers order (is it payed for or is it a pending transaction? )
from order_items
join orders on order_items.order_id = orders.order_id -- THis is what links the item to the order
join loyal_customers on orders.customer_id = loyal_customers.customer_id -- Then this links trhe order to its customer
join products on order_items.product_id = products.product_id; -- lastly, this links the item to the products 

-- Here is what summs up all of the order amounts for each and every customer as well as each total spending
select
loyal_customers.customer_name,
sum(order_items.price) as total_spent
from loyal_customers
join orders on loyal_customers.customer_id = orders.customer_id -- This piece connects cutomers to their correct orders 
join order_items on orders.order_id = order_items.order_id -- This connects the orders to teh items 
group by loyal_customers.customer_name; -- This then groups all of the totals by the customers 

-- I have to make sure to use distinct so that each product only shows up on my table once 
select distinct
products.product_name,
products.price
from products
join order_items on products.product_id = order_items.product_id; -- this only shows products that were ordred 


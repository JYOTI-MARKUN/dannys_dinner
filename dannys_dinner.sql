create schema dannys_diner;
use  dannys_diner;
create table sales( customer_id char,order_date date,product_id smallint);
insert into sales values ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  create table menu(product_id smallint,product_name varchar(30),price int);
  insert into menu values  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  create table members (customer_id char,join_date date);
  insert into members values ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
select s.customer_id ,s.order_date,s.product_id,m.product_name into sell_details from sales as s inner join menu as m on s.product_id=m.product_id; 
  
 # What is the total amount each customer spent at the restaurant? 
select s.customer_id,sum(price) from sales as s inner join menu as m on s.product_id=m.product_id group by customer_id;

# How many days has each customer visited the restaurant?
select customer_id,count(order_date)  as days from sales group by customer_id;

# What was the first item from the menu purchased by each customer?
WITH CTE AS (select customer_id,order_date,product_name,rank() over (partition by customer_id order by order_date) as rnk,
row_number() over (partition by customer_id order by order_date) as rno
from sales as s inner join menu as m on s.product_id=m.product_id) SELECT customer_id,order_date,product_name FROM CTE WHERE rno=1;


# What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name ,count(order_date) as orders  from menu as m inner
 join sales as s on m.product_id=s.product_id
 group by  product_name
 order by count(order_date )desc  limit 1;
 
 
# Which item was the most popular for each customer?
with CTE_TOP AS(select product_name ,count(order_date) as orders,customer_id ,
rank () over(partition by customer_id order by count(order_date) desc) as rnk
,row_number () over(partition by customer_id order by count(order_date) desc) as rno 
 from menu as m inner
 join sales as s on m.product_id=s.product_id group by customer_id,product_name) 
 SELECT product_name,customer_id,orders from CTE_TOP WHERE RNK=1;
 

# Which item was purchased first by the customer after they became a member?
with cte as(select s.customer_id,s.order_date,s.product_id,mb.join_date,product_name, 
rank() over (partition by customer_id order by order_date ) as rnk,
row_number() over (partition by customer_id order by order_date ) as rno from sales as s 
inner join members as mb on s.customer_id=mb.customer_id
inner join menu as m on s.product_id=m.product_id
where order_date>=join_date)
select * from cte where rnk=1 ;


# Which item was purchased just before the customer became a member?
with cte as(select s.customer_id,s.order_date,s.product_id,mb.join_date,product_name, 
rank() over (partition by customer_id order by order_date desc ) as rnk,
row_number() over (partition by customer_id order by order_date desc ) as rno from sales as s 
inner join members as mb on s.customer_id=mb.customer_id
inner join menu as m on s.product_id=m.product_id
where order_date<join_date)
select customer_id,product_name from cte where rnk=1 ;

# What is the total items and amount spent for each member before they became a member?
select s.customer_id,count(product_name) as total_item,sum(price) as amount_spent from sales as s 
inner join members as mb on s.customer_id=mb.customer_id
inner join menu as m ON s.product_id=m.product_id where order_date<join_date group by s.customer_id;


# If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id,any_value(product_name),any_value(price),
sum(case when product_name="sushi" then price*10*2
else price*10 
end ) as points
 from sales as s inner join menu as m on m.product_id=s.product_id group by customer_id;


 

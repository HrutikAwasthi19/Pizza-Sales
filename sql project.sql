create database pizzahut;
use pizzahut;
select * from pizzahut.pizzas;
create table orders
(
order_id int not null primary key,
order_date date not null,
order_time time not null);

create table order_details
(
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);

/*Retrieve the total number of orders placed.*/
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

/*Calculate the total revenue generated from pizza sales.*/
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2)
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
    
/*Identify the highest-priced pizza.*/
select pizza_types.name,pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by price desc
limit 1;

/*Identify the most common pizza size ordered.*/
select pizzas.size,count(order_details.order_details_id) as count_orders
from pizzas join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size 
order by count_orders desc
;

/*List the top 5 most ordered pizza types along with their quantities.*/

select pizza_types.name,sum(order_details.quantity) as total_quantities
from pizza_types join pizzas 
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details 
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by total_quantities desc
limit 5;

/*Join the necessary tables to find the total quantity of each pizza category ordered.*/

select pizza_types.category,sum(order_details.quantity)
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types 
on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.category
order by sum(order_details.quantity) desc;

/*Determine the distribution of orders by hour of the day.*/

select hour(order_time),count(order_id)
from orders
group by hour(order_time);

/*Join relevant tables to find the category-wise distribution of pizzas.*/

select category,count(name) from pizza_types 
group by category;

/*Group the orders by date and calculate the average number of pizzas ordered per day.*/

select round(avg(quantity),0) as avg_pizzas_per_day from
(select orders.order_date , sum(order_details.quantity) as quantity from 
order_details join orders
on order_details.order_id=orders.order_id
group by orders.order_date) as order_quantity;

/*Determine the top 3 most ordered pizza types based on revenue.*/

select pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;
/*Calculate the percentage contribution of each pizza type to total revenue.*/

select pizza_types.category,(sum(order_details.quantity*pizzas.price) / (SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2)
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id))*100 as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category 
order by revenue desc;

/*Analyze the cumulative revenue generated over time.*/

select order_date,sum(revenue) over(order by order_date) as cum_revenue
from 
(select orders.order_date,sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas 
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.order_date) as sales;

/*Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/

select category,name,revenue from
(select category,name,revenue,rank() over(partition by category order by revenue desc) as rn
from 
(
select pizza_types.category,pizza_types.name,sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id= pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b 
where rn<=3;

create database pizzaanalysis;
use pizzaanalysis;

-- Q.1. Retrieve the total numbers of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
-- Q.2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- Q.3. Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Q.4. Identify the most common pizza size ordered

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- Q.5. most ordered pizza types along with their quantities

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS order_sum
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY order_sum DESC
LIMIT 5;


-- Q.6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
ORDER BY quantity DESC;

-- Q.7. Determine the distribution of orders by hour of the day

SELECT 
    HOUR(time) AS hours, COUNT(order_id) AS orders
FROM
    orders
GROUP BY hours
ORDER BY orders DESC;

-- Q.8. Join relaevent tables to find the category wise distribution of pizzas 

SELECT 
    category, COUNT(name) AS counts
FROM
    pizza_types
GROUP BY category;

-- Q.9. Group the orders by date and calculate the average numbers of pizzas ordered per day

SELECT 
    ROUND(AVG(quantity_per_date), 0) AS avg_pizzas_order_per_day
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity_per_date
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity;
    
-- Q.10. Determine the top 3 most ordered pizza type based on revenue

SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price)) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

-- Q.11. Calculate the percentage contribution of each pizza type to total revenue

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100),
            2) AS revenue_percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

-- Q.12. Analyze the cumulative revenue generated over time

select date,
sum(revenue) over(order by date) as cum_revenue
from
(select orders.date,
sum(order_details.quantity* pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.date) as sales;

-- Q.13. Determine the top 3 most order pizza types based on revenue for each pizza category.

select name, revenue from
(select category , name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category ,pizza_types.name,
round(sum(order_details.quantity* pizzas.price),1) as revenue
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category ,pizza_types.name) as a) as b
where rn <=3;












use film_rental;
show tables;
-- 1. What is the total revenue generated from all rentals in the database?
select sum(amount) as Total_Revenue from payment;

-- 2. How many rentals were made in each month_name?
select monthname(payment_date) as month_name,count(rental_id) as Count from payment group by 1 order by 2 desc;

-- 3. What is the rental rate of the film with the longest title in the database?
select rental_rate,title,(length(title)) as Longest_title_length from film group by 1,2 order by 3 desc limit 1;

-- 4. What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")?
select avg(a.rental_rate) Avg_rental_rate from film a 
join inventory b on b.film_id = a.film_id 
join rental c on c.inventory_id = b.inventory_id
join payment d on d.rental_id = c.rental_id where c.rental_date between ("2005-05-05 22:04:30") and ("2005-06-05 22:04:30");

-- 5. What is the most popular category of films in terms of the number of rentals?
select e.name as Category_name,count(f.rental_id) as number_of_rentals from inventory a join film b on b.film_id = a.film_id inner join rental c on c.inventory_id = a.inventory_id
inner join film_category d on d.film_id = b.film_id inner join category e on e.category_id = d.category_id inner join payment f on f.rental_id = c.rental_id
group by 1 order by 2 desc;

-- 6. Find the longest movie duration from the list of films that have not been rented by any customer
select a.title as Movie_title,a.length as Movie_length from film a left join inventory b on b.film_id = a.film_id 
left join rental c on c.inventory_id = b.inventory_id 
left join customer d on d.customer_id = c.customer_id where d.customer_id is null group by 1,2 order by 2 desc;

-- 7. What is the average rental rate for films, broken down by category? (3 Marks)
select c.name,avg(a.rental_rate) as avg_rental_rate from film a join film_category b on 
b.film_id=b.film_id join category c on c.category_id=b.category_id group by 1;

-- 8. What is the total revenue generated from rentals for each actor in the database? (3 Marks)
select concat(a.first_name," ",a.last_name) as Actor_name,sum(e.amount) as Total_revenue from actor a inner join film_actor b on b.actor_id = a.actor_id
inner join inventory c on c.film_id = b.film_id  
inner join rental d on d.inventory_id = c.inventory_id 
inner join payment e on e.RENTAL_id = d.RENTAL_id group by 1 order by 2 desc;

-- 9. Show all the actresses who worked in a film having a "Wrestler" in the description. (3 Marks)
select concat(c.first_name," ",c.last_name) as Name from film a  join film_actor b on b.film_id = a.film_id 
join actor c on c.actor_id = b.actor_id where a.description like "%Wrestler%" group by 1;

-- 10. Which customers have rented the same film more than once? (3 Marks)
select concat(a.first_name," ",a.last_name) as cust_name,e.film_id,count(*) as Count from customer a join rental b on b.customer_id = a.customer_id
inner join payment c on c.rental_id = b.rental_id inner join inventory d on d.inventory_id = b.inventory_id right join film e on e.film_id = d.film_id 
group by 1,2 having Count>1 order by 2 desc;


-- 11. How many films in the comedy category have a rental rate higher than the average rental rate? (3 Marks)
select count(*) as Films_with_comedy_category from film a join film_category b on b.film_id = a.film_id inner join category c on c.category_id = b.category_id 
where c.name = "Comedy" and a.rental_rate > (select avg(rental_rate) from film);

-- 12. Which films have been rented the most by customers living in each city? (3 Marks)

with t1 as (
select a.title as Film_name,e.city as City_name,sum(c.customer_id) as Rental_Count, row_number() over(partition by e.city order by sum(c.customer_id) desc) as Ranks
 from film a 
join inventory b on b.film_id = a.film_id
join customer c on c.store_id = b.store_id 
join address d on d.address_id = c.address_id 
join city e on e.city_id = d.city_id 
group by 1,2 order by 3 desc)
select Film_name,City_name,Rental_Count from t1 where Ranks = 1;

-- 13. What is the total amount spent by customers whose rental payments exceed $200? (3 Marks)
select concat(b.first_name," ",b.last_name) as customer_name,a.customer_id,sum(a.amount) as Total from payment a 
join customer b on b.customer_id = a.customer_id group by 1,2 having Total>200;

-- 14. Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema] (2 Marks)
select * from rental;
select column_name,constraint_name,referenced_table_name,referenced_column_name from INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
where table_name = 'rental' and constraint_name <> 'PRIMARY';

-- 15. Create a View for the total revenue generated by each staff member, broken down by store city with the country name. (4 Marks)

create view staff_revenue as 
(select a.staff_id,concat(b.first_name," ",b.last_name) as staff_name,d.city,e.country,sum(a.amount) as Total_revenue from payment a 
join staff b on b.staff_id = a.staff_id 
join address c on c.address_id = b.address_id 
join city d on d.city_id = c.city_id 
join country e on e.country_id = d.country_id group by 1,2,3);

-- 16. Create a view based on rental information consisting of visiting_day, customer_name, the title of the film, 
-- no_of_rental_days, the amount paid by the customer along with the percentage of customer spending. (4 Marks)
create view rental_information as
(select day(a.rental_date) as day,dayname(a.rental_date) as Dayname,concat(b.first_name," ",b.last_name) as Name_of_Customer,d.title as Film_title,
datediff(a.return_date,a.rental_date) as no_of_rental_days,e.amount,(e.amount/(select sum(amount) from payment where customer_id = b.customer_id))*100 as percentage_customer_spending from rental a
join customer b on b.customer_id = a.customer_id
join inventory c on c.inventory_id = a.inventory_id
join film d on d.film_id = c.film_id
join payment e on e.rental_id = a.rental_id);

-- 17. Display the customers who paid 50% of their total rental costs within one day.
select concat(a.first_name," ",a.last_name) as cust_name from customer a 
join rental b on b.customer_id = a.customer_id
join (select c.rental_id,sum(c.amount) as Total_rental_amount from payment c group by c.rental_id) c on c.rental_id = b.rental_id
join inventory d on d.inventory_id = b.inventory_id
join film e on e.film_id = d.film_id
join payment f on f.rental_id = c.rental_id
where (c.Total_rental_amount)>=(e.rental_rate)/2 and datediff(f.payment_date,b.rental_date)<=1 group by 1;



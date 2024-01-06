/*(Medium) Perform read operation on the designed table created in the above task.*/
/*a. How many female passengers traveled a minimum distance of 600 KMs? */
use travego;
show tables;
set autocommit = 0;
SET SQL_SAFE_UPDATES = 0;
select * from passenger;
select count(*) from passenger where gender='F' and distance >= 600;

/*b. Write a query to display the passenger details whose travel distance is greater than 500 and
who are traveling in a sleeper bus. */

select *  from passenger where distance > 500 and Bus_Type ='sleeper';

/*c. Select passenger names whose names start with the character 'S'.*/

select passenger_name from passenger where Passenger_name like 's%';

/*d. Calculate the price charged for each passenger, displaying the Passenger name, Boarding City,
Destination City, Bus type, and Price in the output.*/

select * from passenger;
select * from price;
select pa.passenger_name,pa.boarding_city,pa.destination_city,pa.bus_type,pr.price from passenger as pa,price as pr;

/*e. What are the passenger name(s) and the ticket price for those who traveled 1000 KMs Sitting in
a bus? */

select pa.passenger_name,pr.price from passenger as pa,price as pr where pa.Distance >1000 and pa.Bus_Type ='sitting';

/*f. What will be the Sitting and Sleeper bus charge for Pallavi to travel from Bangalore to Panaji*/

select bus_type,price from price where distance = (select distance from passenger where passenger_name = 'Pallavi');


/*g. Alter the column category with the value "Non-AC" where the Bus_Type is sleeper*/

select * from passenger;

update passenger set category = "Non-AC" where bus_type = "Sleeper" ;

/*h. Delete an entry from the table where the passenger name is Piyush and commit this change in
the database.*/

delete from passenger where Passenger_name = 'piyush';
commit;

/*i. Truncate the table passenger and comment on the number of rows in the table (explain if
required).*/
truncate passenger;
select * from passenger;

/*j. Delete the table passenger from the database.*/
drop table passenger;
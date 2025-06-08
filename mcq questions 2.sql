-- MCQ QUESTIONS
-- 2
-- You are working with an SQL query designed

-- to calculate the Annual Rate of Change (ARC) for basic rural water services:

-- SELECT name, wat_bas_r - LAG(wat_bas_r) OVER (PARTITION BY (a) ORDER BY (b)) FROM global_water_access ORDER BY name;

-- To accomplish this task, what should you use for placeholders (a) and (b)?
SELECT
    name,
    wat_bas_r - LAG(wat_bas_r) OVER (PARTITION BY name  ORDER BY year) AS ARC
FROM 
global_water_access;

-- 3.

-- What are the names of the two worst-performing employees who visited the fewest sites,

-- and how many sites did the worst-performing employee visit?

-- Modify your queries from the “Honouring the workers” section
select
assigned_employee_id,  count(location_id) as number_of_visit
from visits
group by assigned_employee_id
order by number_of_visit asc
limit 3;

-- Using the employee id to get the employees details to be sent for award

select  employee_name, email, phone_number
from employee
where assigned_employee_id IN (20, 22, 44);

-- 4.
SELECT 
    location_id,
    time_in_queue,
    AVG(time_in_queue) OVER (PARTITION BY location_id ORDER BY visit_count) AS total_avg_queue_time
FROM 
    visits
WHERE 
visit_count > 1 -- Only shared taps were visited > 1
ORDER BY 
    location_id, time_of_record;
    
--      ANSWER : It computes an average queue time for shared taps visited more than once,
--               -- which is updated each time a source is visited.

-- 5 Her address before TRIM
select
employee_name,
address
from employee
where employee_name= "Farai Nia";

-- AFTER TRIM
select
employee_name,
TRIM('33 Angelique Kidjo Avenue  ')
from employee
where employee_name= "Farai Nia";

-- 6.
 
-- How many employees live in Dahabu? 
-- Rely on one of the queries we used in the project to answer this.
select
town_name,
count(employee_name) as number_of_employee_in_each_town from employee
group by town_name;

-- 7.
-- How many employees live in Harare, Kilimani?
-- Modify one of your queries from the project to answer this question.
select
town_name, province_name,
count(employee_name) as number_of_employee_in_each_town from employee
where town_name= "Harare" 
AND  province_name= "Kilimani"
group by town_name; 


-- 8 How many people share a well on average? Round your answer to 0 decimals.

SELECT 
    type_of_water_source,
    ROUND(AVG(number_of_people_served), 0) AS avg_people_per_source
FROM
    water_source
GROUP BY type_of_water_source;

-- 9.
select 
sum(number_of_people_served)
from water_source
where type_of_water_source LIKE "%tap%";

-- 10.
-- Use the pivot table we created to answer the following question. What are the average queue times for the following times?

-- Saturday from 12:00 to 13:00 A lag function can work to help determine the values for each day (hours)
-- Tuesday from 18:00 to 19:00
-- Sunday from 09:00 to 10:00


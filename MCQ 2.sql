SET SQL_SAFE_UPDATES = 0;

-- Cleaning our data
-- Updating employe data

SELECT 
    CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),
            '@ndogowater.gov') AS new_email
FROM
    employee;

-- --Updating the email column 

UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),
            '@ndogowater.gov');
            
            
-- Removing the space from phone number column

SELECT
trim(phone_number)
FROM
employee;

UPDATE employee
SET phone_number= trim(phone_number)
;
-- checking to see if the changes has been implemented
select length(phone_number) from employee;




-- HONOURING THE WORKERS
-- Checking how many of our employee live in each town

select
town_name,
count(employee_name) as number_of_employee_in_each_town from employee
group by town_name;

-- Getting the top 3 field surveyors with the most location visits.

select
assigned_employee_id,  count(location_id) as number_of_visit
from visits
group by assigned_employee_id
order by number_of_visit desc
limit 3;

-- Using the employee id to get the employees details to be sent for award

select  employee_name, email, phone_number
from employee
where assigned_employee_id IN (1, 30, 34);



-- ANALYZING LOCATION
-- Create a query that counts the number of records per town
SELECT town_name, count(location_id) as records_per_town
from location
group by town_name
order by records_per_town desc;

-- Now count the records per province.
SELECT province_name, count(location_id) as records_per_province
from location
group by province_name
order by records_per_province desc;

-- if we count the records for each province, most of them have a similar number of sources,

-- SELECT 
--  province_name, town_name,
--   
--  count(location_id) OVER(PARTITION BY  province_name) AS records_per_town
--   
--   FROM location
--   -- order by records_per_town
--  ;


SELECT province_name, town_name, count(location_id) as records_per_town
from location
group by province_name, town_name
order by province_name, records_per_town desc;

-- Finally, look at the number of records for each location type

select
location_type,
count(location_id) as records_per_location_type
from location
group by location_type;

-- We can see that 60% of all water sources in the data set are in rural communities.
SELECT 23740 / (15910 + 23740) * 100 as pct_of_water_in_rural;

-- DIVING INTO THE WATER SOURCES
-- How many people did we survey in total?
select 
sum(number_of_people_served)
from water_source;

-- How many wells, taps and rivers are there?
select type_of_water_source,
count(number_of_people_served) as number_of_sources
from water_source
group by type_of_water_source
;

-- How many people share particular types of water sources on average?
SELECT 
    type_of_water_source,
    ROUND(AVG(number_of_people_served), 0) AS avg_people_per_source
FROM
    water_source
GROUP BY type_of_water_source;


-- How many people are getting water from each type of source?

select type_of_water_source,
sum(number_of_people_served) as number_of_sources

from water_source
group by type_of_water_source
order by number_of_sources desc;



-- Calculating in percentage based on the total number of people served and total for each water source
select type_of_water_source,
round(sum(number_of_people_served)/27628140
 * 100, 0)as number_of_sources

from water_source
group by type_of_water_source
order by number_of_sources desc;


-- START OF A SOLUTION
-- Write a query that ranks each type of source based
-- on how many people in total use it.

SELECT 
 type_of_water_source, 
 sum(number_of_people_served) as number_of_sources,

 RANK() OVER( order by sum(number_of_people_served) desc) AS rank_of_type_of_water_source
  
  FROM water_source
  where type_of_water_source!= "tap_in_home"
group by type_of_water_source
 ;

-- Which shared taps or wells should be fixed first? first? We can use
-- the same logic; the most used sources should really be fixed first.
-- 1. The sources within each type should be assigned a rank.
-- 2. Limit the results to only improvable sources.
-- 3. Think about how to partition, filter and order the results set.
-- 4. Order the results to see the top of the list.

SELECT DISTINCT
     source_id,
     type_of_water_source,
     number_of_people_served,
     DENSE_RANK() OVER (ORDER BY number_of_people_served DESC ) AS priority_rank
FROM
    md_water_services.water_source
WHERE
    type_of_water_source != 'tap_in_home'  
    order by number_of_people_served desc
LIMIT 50;   

-- ANALYZING QUEUES
-- Question 1:
-- To calculate how long the survey took, we need to get the first and last dates (which functions can find the largest/smallest value), and subtract
-- them. Remember with DateTime data, we can't just subtract the values. We have to use a function to get the difference in days.

SELECT
max(time_of_record),
min(time_of_record),
 DATEDIFF( "2023-07-14", "2021-01-01") AS days_taken_to_complete_survey
 from visits
 ;
 
--  Question 2:
-- Let's see how long people have to queue on average in Maji Ndogo. Keep in mind that many sources like taps_in_home have no queues. These
-- are just recorded as 0 in the time_in_queue column, so when we calculate averages, we need to exclude those rows. Try using NULLIF() do to
-- this.
select 
avg(time_in_queue) as avg_time_in_queue
from visits
where time_in_queue != 0;

-- Using NULLIF aas recommended
SELECT
      AVG(NULLIF(time_in_queue,0)) AS AVG_time_in_queue
FROM visits;

-- 3. What is the average queue time on different days of the week?

select

dayname(time_of_record) as days_of_the_week, 
round(avg(time_in_queue), 0)
from visits
where time_in_queue !=0
group by days_of_the_week;

-- Question 4:
-- We can also look at what time during the day people collect water. Try to order the results in a meaningful way.

select
time_format(time_of_record, "%H:00") AS Hour_of_day,
    round(avg(time_in_queue), 0) as time_in_queue
from visits
group by hour_of_day
order by time_in_queue desc;

-- Wouldn't it be nice to break down
-- the queue times for each hour of each day?

SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
-- Wednesday

ROUND(AVG(

CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,

ROUND(AVG(

CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday


FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times

GROUP BY
hour_of_day
ORDER BY
hour_of_day;

-- We are trying to create a pivot table in the above. Where we have a particular day of the week, it checks the time in queue for a specific
--  hour of the day and calculates the average. It does this for all the  hours for a day as shown in the visits table
-- e.g 2021-01-01 is a Friday, add all the times in  queue and divide by the total number for 9am and also for other years e.g 2023

-- Defining the highest hourly salary on the WEST Region states

WITH west_region as (
SELECT DISTINCT location_id, state
FROM location
WHERE state = 'OR' OR  state = 'CA' OR  state = 'WA') 

,highest_hourly_from as (
SELECT DISTINCT id,
location_id,
job_title,
MAX(inferred_salary_from) as highest_hourly
FROM job_details
WHERE inferred_salary_time_unit IN ('hourly')
GROUP BY id
)
SELECT h.location_id,
w.state
,h.highest_hourly
,h.job_title
,h.id
FROM west_region AS w
JOIN highest_hourly_from AS h
ON  w.location_id = h.location_id


-- CONVERT POST_DATE column
ALTER TABLE job_details ADD newdate DATE;
UPDATE job_details SET newdate = str_to_date(post_date,'%m/%d/%Y')
SELECT * FROM job_details WHERE post_date <> DATE_FORMAT(newdate, '%m-%d-%Y');

-- Pivotion Data w/ CASE WHEN
SELECT 	job_id
		,job_title
        ,inferred_salary_from
        ,inferred_salary_to
        ,category
        ,newdate
FROM job_details
WHERE job_type = 'Contract'
GROUP BY 1,2,3,4,5,6;

-- Self Joins
SELECT distinct
a.inferred_salary_from as salary_from
FROM job_details as a
JOIN job_details as b on a.inferred_salary_from = b.inferred_salary_to
WHERE a.inferred_salary_from <= b.inferred_salary_to

-- Calculation
SELECT 	DISTINCT job_type
				,inferred_salary_from
                ,SUM(inferred_salary_from) OVER (ORDER BY job_type) AS Cumulative
FROM job_details

 -- Window function
SELECT	id, job_title, inferred_salary_from, inferred_salary_to
		, min(inferred_salary_to) OVER (PARTITION BY job_title) AS min_salary_to
FROM job_details
ORDER BY min_salary_to;


-- Recursive CTEs - looking for the number of job_postings/ job_title each company has

WITH RECURSIVE number_of_jobs as ( 
SELECT	company_id,
		company_name
FROM company
WHERE company_id IS NOT NULL
UNION ALL  

SELECT  j.company_id,
		count(j.job_title) AS job_title_n
FROM 	job_details j 
JOIN company n ON n.company_id = j.company_id
GROUP BY company_id
)
SELECT company_id
,company_name 
,j.job_title_n
FROM number_of_jobs n


-- Show Total number of Job posts by each state
WITH CTE_1 as (
SELECT l.location_id, l.state, 
COUNT(j.job_title) as number_of_jobs
FROM location l
JOIN job_details AS j
ON l.location_id = j.location_id
GROUP BY location_id) 

SELECT c.state
,SUM(number_of_jobs)
FROM CTE_1
GROUP BY state

-- Looking for the average and total salaries based on states and Hourly work type
WITH CTE_2 as (
SELECT l.location_id, l.state,  
AVG(inferred_salary_from) AS avg_salary_f,
SUM(inferred_salary_from) AS total_salary_f
FROM location l
JOIN job_details AS j
ON l.location_id = j.location_id
WHERE inferred_salary_time_unit = 'hourly'
GROUP BY location_id) 

SELECT DISTINCT state,
AVG(avg_salary_f) AS Average_salary,
sum(total_salary_f) AS Total_salary
FROM CTE_2
GROUP BY state

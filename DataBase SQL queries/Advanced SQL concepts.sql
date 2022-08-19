-- Task #1
-- Total number of Job posts by each state
-- Average salaries based on states
-- The difference in % between average salaries and the total salary in that state.

WITH Inf_salary AS (
SELECT  l.state,
		j.job_title,
		j.inferred_salary_time_unit AS time_unit,
		(j.inferred_salary_from+j.inferred_salary_to)/2 AS inferred_salary
FROM job_details  AS j
JOIN location AS l
ON j.location_id = l.location_id
WHERE  j.inferred_salary_time_unit  IN ('hourly')
)

,average_and_total AS (
SELECT state, 
time_unit,
AVG(inferred_salary) AS average_salary,
SUM(inferred_salary) AS total_salary,
COUNT(job_title) AS all_jobs
FROM Inf_salary
GROUP by state ORDER BY state)

SELECT 	state,
		all_jobs,
		average_salary,
		total_salary,
        (1 - average_salary/total_salary)*100 as difference
FROM average_and_total


-- Task #2
-- Cities that have <20% of job posts. 

WITH all_jobs AS (
SELECT  DISTINCT l.city,
        COUNT(j.job_title) 
        OVER(PARTITION BY l.city) AS jobs_by_city,
        ROUND(COUNT(j.job_title) 
        OVER (PARTITION BY l.city) * COUNT(DISTINCT j.job_id)/100, 2) AS percent
FROM job_details  AS j
JOIN location AS l
ON j.location_id = l.location_id
GROUP BY city, job_title
ORDER BY jobs_by_city DESC)

SELECT * 
FROM all_jobs
WHERE percent < 20

-- Task #3
-- Selecting the top job boards by job titles making over 100K in salary annualy 

SELECT 	job_board,
		(inferred_salary_from+inferred_salary_to)/2 AS salary,
		COUNT(job_title) AS number_of_job_titles
FROM job_details
WHERE 	(inferred_salary_from+inferred_salary_to)/2  >= 100000 
		AND inferred_salary_time_unit = 'yearly'
GROUP BY job_board, inferred_salary_from, inferred_salary_to
ORDER BY job_board


-- Task #4
--  Top 5 job salaries in US breaking down by job_type/time_unit
-- (Top Annual and Top Hourly rates) - use subquery or CTE 

-- For Hourly
WITH salary_hourly AS (
SELECT 	job_title, 
		job_type,
        inferred_salary_time_unit AS time_unit_hourly,
		(inferred_salary_from+inferred_salary_to)/2 as job_salary_h
FROM job_details
WHERE inferred_salary_time_unit = 'hourly')

SELECT 	job_title,
		job_type,
		time_unit_hourly,
		job_salary_h
FROM salary_hourly 
ORDER BY job_salary_h DESC
LIMIT 5

-- For yearly
WITH salary_yearly AS (
SELECT 	job_title, 
		job_type,
        inferred_salary_time_unit AS time_unit_yearly,
		(inferred_salary_from+inferred_salary_to)/2 as job_salary_y
FROM job_details
WHERE inferred_salary_time_unit = 'yearly')

SELECT 	job_title,
		job_type,
		time_unit_yearly,
        job_salary_y
FROM salary_yearly
ORDER BY job_salary_y DESC
LIMIT 5

-- Task #5
-- Find hirest salaries per city in US. In your output show Job_board, City, salary

WITH inf_salary AS (
SELECT  l.city,
		j.job_board,
		(j.inferred_salary_from+j.inferred_salary_to)/2 AS inferred_salary
FROM job_details  AS j
JOIN location AS l
ON j.location_id = l.location_id
)
SELECT city,
job_board,
MAX(inferred_salary) AS max_salary
FROM inf_salary
GROUP by city, job_board, inferred_salary
ORDER BY inferred_salary DESC
LIMIT 1

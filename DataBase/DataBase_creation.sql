create database bi_marathon;
use bi_marathon

-- Creating a temp table to load  CSV file
CREATE TABLE temp_table (
id int	
,created varchar (50)
,modified varchar (50)
,job_id	varchar (50)
,job_title varchar (255)
,inferred_job_title	varchar (255)
,job_type varchar (255)
,url varchar (255)
,category varchar (255)
,job_board	varchar (50)
,post_date	varchar (50)
,salary_offered	varchar (50)
,inferred_salary_currency varchar (10)
,inferred_salary_from int
,inferred_salary_to	int
,is_remote int
,inferred_seniority_level varchar (50)
,inferred_salary_time_unit varchar (50)
,inferred_max_experience varchar (50)	
,inferred_min_experience varchar (50)
,company_id	int
,indexed_to_es int
,inferred_yearly_from int
,inferred_yearly_to	int
,city_id1 int	
,city_id int
,country_id	int
,state_id int
,html_job_description varchar (255)
,company_name varchar (255)
,company_lat float
,company_lon float
,country varchar (255)
,inferred_country varchar (255)
,country_max_pay_range int
,country_min_pay_range int
,country_pay_range_step	int
,state varchar (10)
,inferred_state	varchar (50)
,city varchar (255)	
,inferred_city varchar (255)
);

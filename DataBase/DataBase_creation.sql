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

ALTER TABLE temp_table
MODIFY html_job_description text;

- create dim table location
CREATE table location (
location_id int not null auto_increment
,country varchar (255)
,inferred_country varchar (255)
,country_max_pay_range int
,country_min_pay_range int
,state varchar (10)
,city varchar (255)
, primary key (location_id)
);

- create dim table COMPANY
CREATE table company (
company_id int not null
,company_name varchar (255)
,company_lat float
,company_lon float
,location_id int
,primary key (company_id)
,FOREIGN KEY (location_id) REFERENCES location (location_id) ON DELETE SET NULL
)

- created dim table JOB_DETAILS
CREATE table job_details (
id int not null
,created varchar (50)
,modified varchar (50)
,job_id varchar (50)
,job_title varchar (255)
,inferred_job_title varchar (255)
,job_type varchar (255)
,inferred_seniority_level varchar (50)
,category varchar (255)
,inferred_salary_from int
,inferred_salary_to int
,inferred_salary_time_unit varchar (50)
,inferred_salary_currency varchar (10)
,post_date varchar (50)
,job_board varchar (50)
,url varchar (255)
,location_id int
,primary key (id)
,FOREIGN KEY (location_id) REFERENCES location (location_id) ON DELETE SET NULL
);

ALTER TABLE job_details
ADD FOREIGN KEY (company_id) REFERENCES company (company_id) ON DELETE SET NULL;

-- create table job_description
CREATE table job_description (
job_id varchar (50) NOT NULL
,html_job_description text
,id int
,PRIMARY KEY (job_id)
,FOREIGN KEY (id) REFERENCES job_details (id) ON DELETE SET NULL
);

- uploading LOCATION table
INSERT IGNORE INTO location (country,inferred_country,country_max_pay_range,country_min_pay_range,state,city)
SELECT DISTINCT country, inferred_country, country_max_pay_range, country_min_pay_range, state, city
FROM temp_table

- uploading COMPANY table
INSERT IGNORE INTO company (company_id,company_name,company_lat,company_lon,location_id)
SELECT DISTINCT t.company_id, t.company_name,t.company_lat,t.company_lon,l.location_id
FROM temp_table t
JOIN location l ON l.city = t.city AND l.state = t.state;

- uploading job_details table
INSERT IGNORE INTO job_details (id,created,modified,job_id,job_title,inferred_job_title,job_type,inferred_seniority_level,category,inferred_salary_from,inferred_salary_to,inferred_salary_time_unit,inferred_salary_currency,post_date,job_board,url,location_id)
SELECT DISTINCT t.id,t.created,t.modified,t.job_id,t.job_title,t.inferred_job_title
,t.job_type,t.inferred_seniority_level,t.category,t.inferred_salary_from,t.inferred_salary_to
,t.inferred_salary_time_unit,t.inferred_salary_currency,t.post_date,t.job_board,t.url,l.location_id
FROM temp_table t
JOIN location l ON l.city = t.city AND l.state = t.state;

INSERT IGNORE INTO job_details (company_id)
SELECT DISTINCT company_id
FROM temp_table

INSERT IGNORE INTO job_description (job_id, html_job_description,id)
SELECT DISTINCT job_id, html_job_description,id
FROM temp_table

TRUNCATE table job_details
TRUNCATE table job_description
TRUNCATE table company
DELETE FROM job_details

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE table job_details;
SET FOREIGN_KEY_CHECKS = 1;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE table job_details;
SET FOREIGN_KEY_CHECKS = 1;

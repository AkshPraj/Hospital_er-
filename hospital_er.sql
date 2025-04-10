-- We first need to create a database for our dataset

create database hospital;
use hospital;
------------------------------------------------------------
------------------------------------------------------------
-- Selecting the database to use.
USE hospital_er;
------------------------------------------------------------
------------------------------------------------------------
-- Let's see the overview  of our dataset
SELECT *
FROM hospital_er
LIMIT 10;

------------------------------------------------------------
-- EXPLORATORY DATA ANALYSIS
------------------------------------------------------------
-- How many rows do we have in our dataset?
SELECT COUNT(*) AS num_rows
FROM hospital_er;

-- How many columns do we have in our dataset?
SELECT COUNT(*) AS num_cols 
FROM information_schema.columns 
WHERE table_name = 'hospital_er';

------------------------------------------------------------
------------------------------------------------------------
-- How many years of data do we have and percentage per year?
SELECT YEAR(date) AS years, COUNT(*) AS counts, ROUND((COUNT(*) / 
(SELECT COUNT(*) FROM hospital_er)) * 100, 1) AS pct
FROM hospital_er
GROUP BY YEAR(date);


-- What day of the week has the highest number of patient visits?
SELECT dayname(date) AS visit_day,
	   COUNT(*) AS number_of_visits
FROM hospital_er
GROUP BY visit_day
ORDER BY number_of_visits DESC;


-- What time of the day do we have the most patient visits
SELECT HOUR(date) AS hour_of_day, COUNT(*) AS number_of_visits
FROM hospital_er
GROUP BY hour_of_day
ORDER BY number_of_visits DESC;

-- what is the daily patient volume

SELECT 
    date,
    COUNT(*) AS total_patients,
    ROUND(AVG(patient_waittime), 2) AS avg_wait_time
FROM 
    hospital_er
GROUP BY date
ORDER BY date;
------------------------------------------------------------
------------------------------------------------------------

-- What are the unique values in our patient gender
SELECT DISTINCT patient_gender
FROM hospital_er;

-- What is the distribution of our pateint gender
SELECT patient_gender, COUNT(*) AS counts, ROUND((COUNT(*) / 
(SELECT COUNT(*) FROM hospital_er)) * 100, 1) AS pct
FROM hospital_er
GROUP BY patient_gender;

-- What is the average age of patients in our data set
SELECT ROUND(AVG(patient_age)) AS average_age
FROM hospital_er;

-- How many race do we have in our dataset
SELECT DISTINCT patient_race
FROM hospital_er;

-- What is the distribution of races in our dataset
SELECT patient_race, COUNT(*) AS counts, ROUND((COUNT(*) / 
(SELECT COUNT(*) FROM hospital_er)) * 100, 1) AS pct
FROM hospital_er
GROUP BY patient_race
ORDER BY pct DESC;

-- What is the average waiting time of patients in our data set?
SELECT AVG(patient_waittime) AS average_waitting_time
FROM hospital_er;

-- What is the Average wait time by different Age group
SELECT 
    CASE 
        WHEN patient_age < 18 THEN 'Under 18'
        WHEN patient_age BETWEEN 18 AND 40 THEN '18-40'
        WHEN patient_age BETWEEN 41 AND 65 THEN '41-65'
        ELSE '65+'
    END AS age_group,
    ROUND(AVG(patient_waittime), 2) AS avg_wait_time
FROM 
    hospital_er
GROUP BY age_group
ORDER BY avg_wait_time ;

-- What is the maximum waiting time of our patient
SELECT MAX(patient_waittime)
FROM hospital_er;

-- What is the minimum waiting time of our patient
SELECT MIN(patient_waittime)
FROM hospital_er;

# What is longest wait time patients per departmnt
SELECT 
    department_referral,
    patient_id,
    patient_waittime
FROM hospital_er her
WHERE patient_waittime = (
    SELECT MAX(patient_waittime)
    FROM hospital_er 
    WHERE department_referral = her.department_referral
)
ORDER BY patient_waittime DESC;

-- How is our patients distributed across departemnt_referral 
SELECT department_referral, COUNT(*) AS counts, ROUND((COUNT(*) / 
(SELECT COUNT(*) FROM hospital_er)) * 100, 1) AS pct
FROM hospital_er
GROUP BY department_referral
ORDER BY counts DESC;

# creating view for er pation admitted and discharged
CREATE VIEW ER_Dashboard AS
SELECT 
    date,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN patient_admin_flag = 'Admitted' THEN 1 ELSE 0 END) AS total_admitted,
    SUM(CASE WHEN patient_admin_flag = 'Discharged' THEN 1 ELSE 0 END) AS total_discharged,
    ROUND(AVG(patient_waittime), 2) AS avg_wait_time,
    COUNT(DISTINCT department_referral) AS distinct_departments
FROM 
    hospital_er
GROUP BY date;

SELECT * FROM ER_Dashboard WHERE avg_wait_time > 30;



-- Employee Management System
CREATE DATABASE EMPLOYEE_MANAGEMENT_SYSTEM;
USE EMPLOYEE_MANAGEMENT_SYSTEM;


-- Table 1: Job Department 
CREATE TABLE IF NOT EXISTS JobDepartment(
Job_ID INT PRIMARY KEY,     
jobdept VARCHAR(50),     
name VARCHAR(100),     
description TEXT,     
salaryrange VARCHAR(50) 
); 



-- Table 2: Salary/Bonus 
CREATE TABLE IF NOT EXISTS SalaryBonus(
salary_ID INT PRIMARY KEY,     
Job_ID INT,     
amount DECIMAL(10,2),     
annual DECIMAL(10,2),     
bonus DECIMAL(10,2), 
CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID) 
ON DELETE CASCADE ON UPDATE CASCADE 
); 



-- Table 3: Employee 
CREATE TABLE IF NOT EXISTS Employee( 
emp_ID INT PRIMARY KEY,     
firstname VARCHAR(50),     
lastname VARCHAR(50),     
gender VARCHAR(10),     
age INT,     
contact_add VARCHAR(100),     
emp_email VARCHAR(100) UNIQUE,     
emp_pass VARCHAR(50),     
Job_ID INT, 
CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID) 
REFERENCES JobDepartment(Job_ID) 
ON DELETE SET NULL 
ON UPDATE CASCADE 
); 
 
 
-- Table 4: Qualification 
CREATE TABLE IF NOT EXISTS Qualification( 
QualID INT PRIMARY KEY, 
Emp_ID INT, 
Position VARCHAR(50), 
Requirements VARCHAR(255), 
Date_In DATE, 
CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID) 
REFERENCES Employee(emp_ID) 
ON DELETE CASCADE 
ON UPDATE CASCADE 
); 
 
 
-- Table 5: Leaves 
CREATE TABLE IF NOT EXISTS   Leaves( 
leave_ID INT PRIMARY KEY,     
emp_ID INT,     
date DATE,     
reason TEXT, 
CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID) 
ON DELETE CASCADE ON UPDATE CASCADE 
); 
 
 
-- Table 6: Payroll 
CREATE TABLE  IF NOT EXISTS  Payroll( 
payroll_ID INT PRIMARY KEY,     
emp_ID INT,     
job_ID INT,     
salary_ID INT,     
leave_ID INT,     
date DATE,     
report TEXT, 
total_amount DECIMAL(10,2), 
CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)         
ON DELETE CASCADE ON UPDATE CASCADE, 
    
CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)  
ON DELETE CASCADE ON UPDATE CASCADE, 
    
CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID) 
ON DELETE CASCADE ON UPDATE CASCADE, 
    
    
CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID) 
ON DELETE SET NULL ON UPDATE CASCADE 
); 


-- Checking data from all tables
select * from JobDepartment;
select * from SalaryBonus;
select * from Employee;
select * from Qualification;
select * from Leaves;
select * from Payroll;




-- Analysis Questions

-- 1. EMPLOYEE INSIGHTS 
-- Q1. How many unique employees are currently in the system?
select COUNT(*)  as EMP_COUNT from EMPLOYEE;


-- Q2. Whic departments have the highest number of employees?
select jd.jobdept, count(e.emp_ID) as employee_count
from employee e
join jobdepartment jd on e.job_id = jd.job_id
group by jd.jobdept
order by employee_count desc;


-- Q3. What is the average salary per department?
select jd.jobdept,avg(sb.amount) as avgsalary
from jobdepartment jd
join salarybonus sb 
on jd.job_id = sb.job_id
group by jd.jobdept
order by avgsalary desc;


-- Q4. Who are the top 5 highest-paid employees? 
select e.emp_id,e.firstname,e.lastname,pr.total_amount
from employee e
join payroll pr
on e.job_id = pr.job_id
order by pr.total_amount desc
limit 5;


-- Q5. What is the total salary expenditure across the company? 
select sum(total_amount) as total_salary_expenditure
from payroll;




-- 2. JOB ROLE AND DEPARTMENT ANALYSIS 
-- Q1. How many different job roles exist in each department? 
select jobdept as JobDept, count(job_id) as Total_JobRoles
from jobdepartment 
group by jobdept;


-- Q2. What is the average salary range per department? 
select jd.jobdept,avg(sb.amount) as avgsalary
from jobdepartment jd
join salarybonus sb 
on jd.job_id = sb.job_id
group by jd.jobdept
order by avgsalary desc;


-- Q3. Which job roles offer the highest salary? 
select jd.name as job_role, sb.amount
from jobdepartment jd
join salarybonus sb
on jd.job_id = sb.job_id
order by sb.amount desc;


-- Q4. Which departments have the highest total salary allocation?
select jd.jobdept,sum(sb.amount) as total_salary_allocation
from jobdepartment jd
join salarybonus sb
on jd.job_id = sb.job_id
group by jobdept
order by total_salary_allocation desc;




-- 3. QUALIFICATION AND SKILLS ANALYSIS 
-- Q1. How many employees have at least one qualification listed? 
select count(emp_id) as qualified_employees
from qualification;


-- Q2. Which positions require the most qualifications? 
select position,count(*) as qualification_count
from qualification
group by position
order by qualification_count desc;


-- Q3. Which employees have the highest number of qualifications? 
select e.emp_id,e.firstname,count(q.QualId) as qualification_count
from employee e
join qualification q on e.emp_id  = q.emp_id
group by e.emp_id,e.firstname
order by qualification_count desc;
select*from leaves;




-- 4. LEAVE AND ABSENCE PATTERNS 
-- Q1. Which year had the most employees taking leaves? 
select year(date) as year, count(emp_id) as employees_on_leave
from leaves
group by year(date)
order by employees_on_leave desc;


-- Q2. What is the average number of leave days taken by its employees per department?
SELECT jd.jobdept, AVG(l.leave_count) AS avg_leave_days
FROM (
    SELECT emp_ID, COUNT(*) AS leave_count
    FROM Leaves
    GROUP BY emp_ID
) l
JOIN Employee e ON l.emp_ID = e.emp_ID
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;


-- Q3. Which employees have taken the most leaves? 
select e.emp_id,e.firstname,e.lastname,count(l.leave_id) as leaves_count
from employee e
join leaves l
on e.emp_id = l.emp_id
group by e.emp_id,e.firstname
order by leaves_count desc;


-- Q4. What is the total number of leave days taken company-wide? 
select count(leave_id) as total_leaves
from leaves;


-- Q5. How do leave days correlate with payroll amounts? 
select pr.total_amount,
		count(l.leave_id) as total_leaves
	from payroll pr
left join leaves l on pr.emp_id = l.emp_id
group by pr.total_amount
order by total_leaves desc;




-- 5. PAYROLL AND COMPENSATION ANALYSIS 
-- Q1. What is the total monthly payroll processed? 
select month(date) as month, sum(total_amount) as monthly_payroll
from payroll pr 
group by month(date);


-- Q2.	What is the average bonus given per department? 
select jd.jobdept,avg(sb.bonus) as avg_salarybonus
from jobdepartment jd
join salarybonus sb
on jd.job_id = sb.job_id
group by jd.jobdept
order by avg_salarybonus desc;



-- Q3. Which department receives the highest total bonuses?
select jd.jobdept,sum(sb.bonus) as highest_salarybonus
from jobdepartment jd
join salarybonus sb
on jd.job_id = sb.job_id
group by jd.jobdept
order by highest_salarybonus desc
limit 1;


-- Q4. What is the average value of total_amount after considering leave deductions? 
select avg(total_amount) as avg_pay
from payroll;


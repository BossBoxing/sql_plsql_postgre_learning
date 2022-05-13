select employee_id , first_name , salary "Salary" , ((salary * 10/100)+salary) "Salary +10%"
from tn_bossboxing_employee ;

select distinct department_id , job_id 
from tn_bossboxing_employee tbe ;

select first_name,last_name  , job_id , salary
from tn_bossboxing_employee tbe 
where salary < 18000
order by first_name;

select first_name,last_name  , job_id , salary , manager_id 
from tn_bossboxing_employee tbe 
where job_id LIKE '%REP%' and manager_id is not NULL
order by first_name;

select *
from tn_bossboxing_employee tbe 
where manager_id not in(100,101) 
and salary between 10000 and 18000
order by salary,manager_id ;

select boss_emp.employee_id,
boss_emp.first_name || ' ' || boss_emp.last_name as "Full Name",
boss_emp.job_id ,jobs.job_title,boss_emp.department_id,td.department_name,
boss_emp.manager_id,
manager_emp.employee_id,
coalesce(manager_emp.first_name || ' ' || manager_emp.last_name,'No Manager') as "Manager name"
from tn_bossboxing_employee boss_emp
inner join tn_jobs jobs
on boss_emp.job_id = jobs.job_id
inner join tn_departments td 
on boss_emp.department_id  = td.department_id
left join tn_bossboxing_employee manager_emp
on boss_emp .manager_id = manager_emp.employee_id ;

select emp.department_id,dept.department_name,avg(emp.salary) as AvgSalary
from tn_bossboxing_employee emp
inner join tn_departments dept
on emp.department_id = dept.department_id
group by emp.department_id ,dept.department_name
order by emp.department_id;

select emp.department_id,dept.department_name,avg(emp.salary)
from tn_bossboxing_employee emp
inner join tn_departments dept
on emp.department_id = dept.department_id
group by emp.department_id,dept.department_name
order by emp.department_id;


select emp.department_id,dept.department_name,avg(emp.salary)
from tn_bossboxing_employee emp
inner join tn_departments dept
on emp.department_id = dept.department_id
group by emp.department_id,dept.department_name
having emp.salary = (
		bselect min(test_avg)
		from (select emp.department_id as test_id,dept.department_name as test_name,avg(emp.salary) as test_avg
		from tn_bossboxing_employee emp
		inner join tn_departments dept
		on emp.department_id = dept.department_id
		group by test_id,test_name) as test)
order by emp.department_id;

select emp.department_id,dept.department_name,avg(emp.salary)
from tn_bossboxing_employee emp
inner join tn_departments dept
on emp.department_id = dept.department_id
group by emp.department_id ,dept.department_name
having avg(emp.salary) > 5000
order by emp.department_id;

select *
from tn_bossboxing_employee emp
where emp.salary < (select salary
					from tn_bossboxing_employee emp
					where LOWER(emp.first_name) = 'nancy');

select *
from tn_bossboxing_employee tbe 
where tbe.first_name = 'Nancy';
					
select dept.department_id,dept.department_name,count(emp.employee_id) as "n_employee"
from tn_bossboxing_employee emp
inner join tn_departments dept
on emp.department_id = dept.department_id
group by dept.department_id,dept.department_name
having count(emp.department_id) < (
				select count(emp.department_id)
				from tn_bossboxing_employee emp
				inner join tn_departments dept
				on emp.department_id = dept.department_id
				where lower(dept.department_name) like '%ship%'
				group by dept.department_id,dept.department_name
				)
order by dept.department_id;

select dept.department_id
,		dept.department_name
,		coalesce(dept.manager_id,0) as "manager_id"
,		coalesce(emp.first_name || ' ' || emp.last_name,'No Manager') as "Manager Full Name"
from tn_departments dept
left join tn_bossboxing_employee emp
on dept.manager_id = emp.employee_id
group by dept.department_id,dept.department_name,dept.manager_id,emp.first_name,emp.last_name
order by dept.manager_id ;


---------- TEST ------------

-- 01

select emp.employee_id
,emp.first_name || ' ' || emp.last_name as "full_name"
,emp.manager_id
,emp.salary as old_salary
,case 
		when emp.manager_id = 100 then (emp.salary*0.15)
		when emp.manager_id = 102 then (emp.salary*0.07)
		else 0
end as "Extra Bonus"
,case 
		when emp.manager_id = 100 then (emp.salary*0.15)+emp.salary
		when emp.manager_id = 102 then (emp.salary*0.07)+emp.salary
		else emp.salary
end as "new_salary"
from tn_bossboxing_employee emp
order by "Extra Bonus" DESC

-- 02

select emp.employee_id
,emp.first_name || ' ' || emp.last_name as "Full Name"
,emp.job_id
,emp.department_id
,dept.department_name 
,manager.first_name || ' ' || manager.last_name as "Manager Full Name"
from tn_bossboxing_employee emp
inner join tn_departments dept
on dept.department_id = emp.department_id
inner join tn_employees manager
on dept.manager_id = manager.employee_id
where emp.job_id ilike '%pro%';

-- 03

-- Main
select *
from tn_bossboxing_employee emp
where emp.manager_id = (select emp.employee_id
						from tn_bossboxing_employee emp
						inner join tn_departments dept
						on emp.employee_id = dept.manager_id
						where dept.department_name ilike 'it');

	-- draft subquery
	select emp.employee_id
	from tn_bossboxing_employee emp
	inner join tn_departments dept
	on emp.employee_id = dept.manager_id
	where dept.department_name ilike 'it';

-- 04

select emp.employee_id
,emp.first_name || ' ' || emp.last_name as "Full Name"
,emp.hire_date as old_gire_date
,to_char(emp.hire_date + interval '543 year','DAY DD MONTH YYYY') as new_hire_date
from tn_bossboxing_employee emp;

-- 05

insert into tn_max_employee (employee_id,first_name,last_name,email,phone_number,hire_date,job_id,salary,department_id) 
values (6501,'Hudsawat','Akkati','Boss','0981805754',to_date('2022-03-05','YYYY-MM-DD'),'TN',0,9);

select *
from tn_max_employee emp;

-- 06

select *
from tn_bossboxing_employee emp limit 1;

-- 07

select current_timestamp ;

select *
from max_item;

insert into max_item (ou_code,item_id,item_name,unit_price,cr_by,cr_date) values ('65','6501','Hudsawat',9,'Boss',current_timestamp);

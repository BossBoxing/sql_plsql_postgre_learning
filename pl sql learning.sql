

do $$
	declare
		rec_emp tn_employees%rowtype;
		--v_new_salary tn_employees.salary%type;
	begin
		select 	emp.employee_id
		,		emp.first_name || ' ' || emp.last_name as "name"
		into rec_emp.employee_id,rec_emp.first_name
		from tn_employees emp limit 1;
		raise notice 'ID : % Name : %' ,rec_emp.employee_id,rec_emp.first_name;
end $$

do $$
	declare
		rec_emp tn_employees%rowtype;
		v_new_salary tn_employees.salary%type;
	begin
		select 	emp.employee_id
		,		emp.first_name || ' ' || emp.last_name as "name"
		,		emp.salary 
		,		(emp.salary + (emp.salary*0.10))
		into 	rec_emp.employee_id
		,		rec_emp.first_name
		,		rec_emp.salary
		,		v_new_salary
		from tn_employees emp limit 1;
		raise notice 'ID : % Name : % old_salary : % new_salary : % , %' 
		,	rec_emp.employee_id
		,	rec_emp
		.	first_name
		,	rec_emp.salary
		,	v_new_salary
		,	' ' || '%';
end $$

do $$
	declare
		--emp_rec tn_employees%rowtype;
		emp_cs cursor is
			select
				emp.employee_id,
				emp.first_name,
				emp.last_name,
				emp.email,
				emp.phone_number,
				dept.department_id as dept_id,
				dept.department_name as dept_name,
				manager.employee_id as man_id,
				manager.first_name as man_fname,
				manager.last_name as man_lname
			from tn_employees emp
			inner join tn_departments dept
				on (emp.department_id = dept.department_id)
			inner join tn_employees manager
				on (emp.manager_id = manager.employee_id)
			where emp.manager_id in (100,114)
			order by emp.employee_id;
	begin
		raise notice '=========== OUTPUT ===========';
		for emp_rec in emp_cs loop
			raise notice '-----------------------------------------------------';
			raise notice 'emp_id : % | emp_fullname : % | email : % | tel : % | 
			dept_id : % | dept_name : % | 
				manager_id : % | manager_fullname : %'
			,	emp_rec.employee_id
			,	emp_rec.first_name || ' ' || emp_rec.last_name
			,	emp_rec.email
			,	emp_rec.phone_number
			,	emp_rec.dept_id
			,	emp_rec.dept_name
			,	emp_rec.man_id
			,	emp_rec.man_fname || ' ' || emp_rec.man_lname;
		end loop;
		raise notice '=========== Finish ===========';
end; $$

do $$
declare
	dept_cs cursor is
		select 
			dept.department_id,
			dept.department_name,
			round(avg(emp.salary),2) as avgsalary
		from tn_employees emp
		inner join tn_departments dept
			on (emp.department_id = dept.department_id)
		group by dept.department_id,dept.department_name
		order by avgsalary desc;
begin
	for dept_rec in dept_cs loop
		raise notice '----------------------------------------------';
		raise notice 'dept_id: % dept_name: % 
						                   dept_avg_salary: % ',
								dept_rec.department_id,
								dept_rec.department_name,
								dept_rec.avgsalary;
		if dept_rec.avgsalary >= 10000 then
			raise notice '								Very Good';
		elsif dept_rec.avgsalary >= 8000 and dept_rec.avgsalary < 10000 then
			raise notice '								Good';
		elsif dept_rec.avgsalary >= 5000 and dept_rec.avgsalary < 8000 then
			raise notice '								Cool';
		else
			raise notice '								So Bad';
		end if;
	end loop;
end; $$



do $$
declare
	v_emp_id tn_employees.employee_id%type;
begin
	select employee_id
	into strict v_emp_id
	from tn_employees
	where employee_id = 99999;
	raise notice 'test % ',v_emp_id;
exception when no_data_found then
		raise notice 'no this employee_id';
end; $$

--do $$
create or replace function tn_boss_get_mercenary(p_emp_id numeric(4))
returns varchar
language plpgsql
as $$
declare
	v_emp_id tn_employees.employee_id%type := p_emp_id;
	v_emp_cs cursor is
		select manager.first_name || ' ' || manager.last_name as fullname,count(emp.employee_id) as n_emp
		from tn_employees manager
		left join tn_employees emp
			on (manager.employee_id = emp.manager_id)
		where manager.employee_id = v_emp_id
		group by manager.first_name,manager.last_name,manager.employee_id;
begin
	for emp_rec in v_emp_cs loop
		--raise notice 'debug: % ',emp_rec.n_emp;
		if emp_rec.n_emp > 1 then
			--raise notice 'หัวหน้า % มีลูกน้องหลายคน',v_emp_id;
			return ('หัวหน้า ' || v_emp_id || ' มีลูกน้องหลายคน');
		elsif emp_rec.n_emp = 1 then	
			--raise notice 'พนักงานชื่อ %, ลูกน้องของ %',emp_rec.fullname,v_emp_id;
			return ('หัวหน้า ' || emp_rec.fullname || ',มีลูกน้องในทีม 1 คน');
		else
			--raise notice 'หัวหน้า (%) ไม่มีลูกน้อง',v_emp_id;
			return ('หัวหน้า ' || v_emp_id || ' ไม่มีลูกน้อง');
		end if;
	end loop;
	return ('ไม่มีพนักงานรหัส' || v_emp_id || ' ');
end; $$;

select 	tn_boss_get_mercenary(150) as "testcase: no mercenary person",
		tn_boss_get_mercenary(201) as "testcase: only 1 person",
		tn_boss_get_mercenary(9999) as "testcase: no this id in data",
		tn_boss_get_mercenary(100) as "testcase: more 1 person"
		;

--do $$
create or replace procedure  tn_boss_add_bonus2(p_emp_id numeric(4),p_bonus numeric(3))
--returns tn_max_employees.salary%type
language plpgsql
as $$
declare
	v_emp_id_target tn_max_employees.employee_id%type;
	v_emp_salary tn_max_employees.salary%type;
begin
	select 	emp.employee_id
	,		emp.salary
	into strict v_emp_id_target,v_emp_salary
	from tn_max_employees emp
	where emp.employee_id = p_emp_id;

	update tn_max_employees
	set salary = v_emp_salary+((p_bonus/100)*v_emp_salary)
	where employee_id = p_emp_id;
	--return v_emp_salary+((p_bonus/100)*v_emp_salary);
end; $$;

call tn_boss_add_bonus2(101,10);

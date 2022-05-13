
-- Exam for PL SQL
-- @KSS
-- Mr.Hudsawat Akkati (Boss)

-- 01

do $$
declare
	v_base numeric(4) := 34;
	v_height numeric(4) := 105;
begin
	raise notice 'base: %,height: %, answer: %',v_base,v_height,(0.5*v_base*v_height);
end; $$

-- 02

do $$
declare
	v_text varchar(50) := '';
begin
	for i in REVERSE 9..1 loop
		for j in REVERSE i..1 loop
			v_text := v_text || '*';
		end loop;
		raise notice '%',v_text;
		v_text := '';
	end loop;
end; $$

-- 03

do $$
declare
	v_text varchar(50) := '*';
begin
	
	for i in 1..5 loop
		raise notice '%',v_text;
		v_text := v_text || '**';
	end loop;
	
	for i in 1..5 loop
		--raise notice 'debug: % %',i,length(v_text);
		v_text := substring(v_text,1,length(v_text)-2);
		raise notice '%',v_text;
	end loop;
end; $$

-- 04

--do $$
create or replace procedure  boss_ppu_upd_emp_salry(p_emp_id numeric(4),p_bonus numeric(3))
--returns tn_max_employees.salary%type
language plpgsql
as $$
declare
	v_emp_id_target tn_max_employees.employee_id%type;
	v_emp_salary tn_max_employees.salary%type;
	v_emp_new_salary tn_max_employees.salary%type;
begin

	--select row of target employee
	select 	emp.employee_id
	,		emp.salary
	into strict v_emp_id_target,v_emp_salary
	from tn_max_employees emp
	where emp.employee_id = p_emp_id;

	-- check percent
	if p_bonus < 0 then
		raise notice 'ไม่สามารถกรอกโบนัส (เปอร์เซ็น) ติดลบได้';
	else
		-- cal new_salary
		v_emp_new_salary := v_emp_salary+((p_bonus/100)*v_emp_salary);
		-- update new salary to database
		update tn_max_employees
		set salary = v_emp_new_salary
		where employee_id = p_emp_id;
	
		raise notice '**** ทำรายการเสร็จสิ้น ****';
		raise notice 'emp_id: %, bonus(percent): %, old_salary: %, new_salary: %',p_emp_id,p_bonus,v_emp_salary,v_emp_new_salary;
	
	end if;
	exception
		when no_data_found then
			raise notice 'ไม่ค้นพบพนักงานไอดีนี้';
end; $$;

call boss_ppu_upd_emp_salry(190,150);
call boss_ppu_upd_emp_salry(190,-10);
call boss_ppu_upd_emp_salry(999,150);

-- 05

create or replace function boss_fpu_show_day(p_bdate date)
returns varchar
language plpgsql
as $function$
declare
	v_day varchar;
begin
	v_day := to_char(p_bdate,'day');
	return (v_day);
exception 
	when OTHERS then -- ใช้ไม่ได้
		raise notice 'โปรดเช็ควันที่ให้ถูกต้อง เช่น 11/05/2021';
end; $function$

select 	boss_fpu_show_day(current_date) as today
,		boss_fpu_show_day(current_date + 1) as tomorrow
,		boss_fpu_show_day('11/05/2021') as testcase
--,		boss_fpu_show_day('11/05/2021 3') as testcase2warnsyntax;

-- 06

create or replace function boss_get_fullname_emp(p_emp_id numeric(4))
returns tn_max_employees.first_name%type
language plpgsql
as $function$
declare
	--p_emp_id tn_max_employees.employee_id%type := 190; 
	v_emp_fname tn_max_employees.first_name%type;
	v_emp_lname tn_max_employees.last_name%type;
begin
	-- find fname,lname of target employee
	select emp.first_name,emp.last_name
	into strict v_emp_fname,v_emp_lname
	from tn_max_employees emp
	where p_emp_id = emp.employee_id
	limit 1;
	
	-- check name
	if v_emp_fname <> '' and v_emp_lname <> '' then
		--raise notice 'name: %',concat(v_emp_fname,' ',v_emp_lname);
		return concat(v_emp_fname,' ',v_emp_lname);
	end if;

exception
	when no_data_found then
		raise notice 'ไม่ค้นพบพนักงานไอดี %',p_emp_id;
end; $function$

select 	boss_get_fullname_emp(100) as id_100
,		boss_get_fullname_emp(101) as id_101
,		boss_get_fullname_emp(190) as id_190;

-- 07

create or replace procedure boss_add_organize(p_ou_code tn_su_organize.ou_code%type,
												p_ou_name tn_su_organize.ou_name%type,
														p_ou_note tn_su_organize.note%type)
language plpgsql
as $function$
declare
	--p_ou_code tn_su_organize.ou_code%type := 'S01';
	--p_ou_name tn_su_organize.ou_name%type := 'BossBoxing Company,Co.';
	--p_ou_note tn_su_organize.note%type := 'Whiskey,Drugs,Beer';
	v_flag_ou_code tn_su_organize.ou_code%type;
begin
	select ogn.ou_code
	into strict v_flag_ou_code
	from tn_su_organize ogn
	where ogn.ou_code = p_ou_code
	limit 1;

	if v_flag_ou_code <> '' then
		raise notice 'กรุณากรอกใหม่ ข้อมูลมีปัญหา ex.มีข้อมูลเดิมในฐานข้อมูลอยู่แล้ว';
	end if;

	exception 
		when no_data_found then
			-- ไม่มีข้อมูลในระบบ สามารถเพิ่มได้
			insert into tn_su_organize (ou_code,ou_name,note)
			values (p_ou_code,p_ou_name,p_ou_note);
end; $function$

call boss_add_organize('S01','BossBoxing Company,Co.','Whiskey,Drugs,Beer');

create or replace procedure boss_cancel_cust(p_target_cust_id tn_boss_customers.cust_id%type)
language plpgsql
as $function$
declare
	--p_target_cust_id tn_boss_customers.cust_id%type := '100';
	v_flag_target tn_boss_customers.cust_id%type;
begin 
	select cust.cust_id 
	into strict v_flag_target
	from tn_boss_customers cust
	where cust.cust_id = p_target_cust_id;

	if v_flag_target <> '' then -- ข้อมูลถูกต้อง สามารถลบได้
		delete 
		from tn_boss_customers cust
		where cust.cust_id = p_target_cust_id;
		raise notice 'deleted';
	else -- เคสที่เกิดขึ้นได้ยาก
		raise notice 'กรอกใหม่อีกครั้ง';
	end if;
exception
	when no_data_found then
		raise notice 'ไม่พบลูกค้ารหัส %',p_target_cust_id;
end; $function$

insert into tn_boss_customers (ou_code,cust_id,cust_name,address,telephone)
values ('01','100','Google Facebook','US','191');

call boss_cancel_cust('100');

-- 09

create or replace function boss_grader(p_score numeric(4))
returns varchar
language plpgsql
as $function$
declare
	--p_score numeric(4) := 100;
	v_grade varchar;
begin	
	if p_score > 100 then
		v_grade := 'กรุณากรอกใหม่';
	elsif p_score >= 80 then
		v_grade := 'A';
	elsif p_score >= 70 then
		v_grade := 'B';
	elsif p_score >= 60 then
		v_grade := 'C';
	elsif p_score >= 50 then
		v_grade := 'D';
	elseif p_score >= 0 then
		v_grade := 'F';
	else
		v_grade := 'กรุณากรอกใหม่';
	end if;
	
	return (v_grade); --raise notice 'score: %,  grade: % ',i,v_grade;
	--end loop;
end; $function$

select 	boss_grader(-5) as in_minus5
,		boss_grader(0) as in_0
,		boss_grader(5) as in_5
,		boss_grader(50) as in_50
,		boss_grader(60) as in_60
,		boss_grader(79) as in_79
,		boss_grader(81) as in_81
,		boss_grader(100) as in_100
,		boss_grader(105) as in_105;
--,		boss_grader('google') as in_google;

-- 10

--test single-row func
select floor(20000.50);

drop function boss_convert_to_money;

create or replace function boss_convert_to_money(p_target_money numeric(13,2))
returns varchar
language plpgsql
as $function$
declare
	--p_target_money numeric(13,2) := 9999999;
	v_calculed_money varchar;
begin
	if p_target_money <> p_target_money::int then --raise notice 'Decimal number'; -- have .15 , .23 not .00
		v_calculed_money := to_char(p_target_money,'LFM 9,999,999,999,999.99');
	else
		v_calculed_money := to_char(p_target_money,'LFM 9,999,999,999,999');
	end if;
	
	return (v_calculed_money);
end; $function$

select 	boss_convert_to_money(0) as in_0
,		boss_convert_to_money(-1000) as in_minus100
,		boss_convert_to_money(1.00) as in_1_00
,		boss_convert_to_money(5000.15) as in_5000_15
,		boss_convert_to_money(1000000000) as in_1000000000;





-- BossBoxing SS6501 [Mr.Hudsawat Akkati]
-- @KSS
-- Trainee

-- *** Note!! *** ---
-- มีการเรียกใช้ตารางจากที่แปลกๆบ้าง เนื่องจากต้องหยิบยืม table ของคนอื่นที่สร้างไว้แล้ว ขอขอบคุณครับที่กรุณาสร้างไว้ให้ -- 
-- thanks k.bnk,k.bank for tn_bnk_... m tn_bank_... tables --

-- Exam SQL --

-- 01

create table tn_boss_customers(
	ou_code varchar(3) not null,
	cust_id varchar(5) not null,
	cust_name varchar(100),
	address varchar(100),
	telephone varchar(10),
	credit_lim int,
	curr_bal int,
	prog_id varchar(20),
	cr_by varchar(20),
	cr_date date,
	upd_by varchar(20),
	upd_date date,
	primary key (ou_code,cust_id),
	constraint fk_su_organize
	foreign key(ou_code)
	references su_organize(ou_code)
);

create table tn_boss_employee(
	ou_code varchar(3) not null,
	emp_id varchar(5) not null,
	emp_name varchar(100),
	salary int,
	address varchar(100),
	telephone varchar(10),
	prog_id varchar(20),
	cr_by varchar(20),
	cr_date date,
	upd_by varchar(20),
	upd_date date,
	primary key(emp_id,ou_code),
	constraint fk_su_organize
	foreign key(ou_code)
	references su_organize(ou_code)
);


-- 02

insert into tn_boss_employee (ou_code,emp_id,emp_name,salary,address,telephone)
values ('01','1010','PIYA',3500,'SEELOM','2381101');
insert into tn_boss_employee (ou_code,emp_id,emp_name,salary,address,telephone)
values ('01','1598','PINYO',4985,'SIAM SQR.','2210051');

insert into tn_boss_customers (ou_code,cust_id,cust_name,address,telephone,credit_lim,curr_bal)
values ('01','100','SOPHA','BANGKOK','2174000',300000,100000);
insert into tn_boss_customers (ou_code,cust_id,cust_name,address,telephone,credit_lim,curr_bal)
values ('01','110','SILEE','BANGKOK','2520091',400000,200000);

-- 03

delete
from tn_boss_customers cust
where cust.address ilike '%chaingmai%';

-- 04

update tn_item
set unit_price = coalesce(unit_price + (unit_price*0.03),NULL);

-- 05

update tn_boss_employee
set address = 'PARAM 4',telephone = '2375102'
where emp_name ilike '%ภิญโญ%';

-- 06

select * from tn_boss_employee;

-- 07

select emp_id,salary
from tn_boss_employee;

-- 08

select * from tn_bnk_item
order by unit_price;

-- 09

select orders.cust_id 
,	orders.emp_id
,	orders.item_id
,	orders.qty
from tn_bnk_orders orders
order by orders.cust_id,orders.emp_id,orders.item_id;

-- 10

select *
from tn_boss_employee emp
where salary > 50000
order by salary desc;

-- 11

select *
from tn_boss_customers cust
where address ilike '%chiangmai%' and cust.curr_bal > 0;

-- 12
select item.item_id,item.item_name
from tn_bnk_item item
where item.onhand_qty between 1000 and 5000
order by item.item_id desc;

-- 13
select *
from tn_boss_employee emp
where emp.emp_name ilike 'p%';

-- 14
select *
from tn_boss_employee emp
where salary > (
				select salary
				from tn_boss_employee emp
				where emp.emp_name ilike '%sukchai%'
);

-- 15
select item.item_id,item.item_name,item.onhand_qty 
from tn_bnk_item item
where item.onhand_qty <> 0 or item.onhand_qty is not null;

-- 16
select cust.cust_name,cust.address,(cust.credit_lim - cust.curr_bal) as "diff of credit limit and current balance"
from tn_bank_customer cust
order by cust.cust_name;

-- 17
select *
from tn_bnk_item item
where coalesce(item.onhand_qty,0) < coalesce(item.order_qty,0)  ; -- โกดัง น้อยกว่า ที่สั่งซื้อขั้นต่ำ

-- 18
select cust.cust_id,cust.credit_lim
from tn_boss_customers cust
where cust.address ilike (
							select cust.address
							from tn_boss_customers cust
							where cust.cust_id ilike '140'
);

-- 19
select emp.emp_id,emp.emp_name,count(orders.emp_id) as "n of orders per emp"
from tn_bank_employee emp
inner join tn_bnk_orders orders
on orders.emp_id = emp.emp_id
group by emp.emp_id,emp.emp_name;

-- 20
select orders.order_id,item.item_name
from tn_bnk_orders orders
inner join tn_bnk_item item
on orders.item_id = item.item_id
order by orders.order_id desc;

-- 21
select empsale.emp_name,sum(empsale.sumofsales) as "Sum of n_sales in orders"
from (select emp.emp_name,sum(orders.qty) as sumofsales
	from tn_bank_employee emp
	inner join tn_bnk_orders orders
	on orders.emp_id = emp.emp_id
	group by emp.emp_name,orders.item_id
	order by emp.emp_name) as empsale
group by empsale.emp_name;

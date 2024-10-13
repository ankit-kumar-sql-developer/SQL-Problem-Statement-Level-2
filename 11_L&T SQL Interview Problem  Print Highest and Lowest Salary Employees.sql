
drop table if exists #employee
create table #employee (
emp_name varchar(10),
dep_id int,
salary int);
delete from #employee;
insert into #employee values 
('Siva',1,30000),('Ravi',2,40000),('Prasad',1,50000),('Sai',2,20000)

-- Print highest & lowest salary emp in each department

-- Solution 1 Case when & aggregation join 
;with cte as  (
select dep_id, min(salary) as min_sal , max(salary) as max_sal
from #employee group by dep_id )
Select e.dep_id,
Max(case when salary = max_sal then emp_name else null end) as max_sal_emp,
Max(case when salary = min_sal then emp_name else null end) as min_sal_emp
from #employee e 
inner join cte c on e.dep_id = c.dep_id group by e.dep_id

-- Solution 2
;with cte as (
Select *,
row_number() over (partition by dep_id order by salary desc) as rn_desc,
row_number() over (partition by dep_id order by salary asc) as rn_asc
from #employee )
Select dep_id,
Max(case when rn_desc=1 then emp_name end) as max_sal_emp,
Max(case when rn_asc=1 then emp_name  end) as min_sal_emp
from cte group by dep_id

-- What happens if two employee have highest salary ?
--
select distinct dep_id, 
FIRST_VALUE(emp_name) over(partition by dep_id order by salary desc) as emp_max_salary,
FIRST_VALUE(emp_name) over(partition by dep_id order by salary) as emp_min_salary
from #employee

--
select a.dep_id,a.emp_max,b.emp_min from 
(select dep_id, emp_name as emp_max , 
dense_rank() over (partition by dep_id order by salary desc) as max_rk from #employee) a
inner join 
(select dep_id, emp_name as emp_min ,
dense_rank() over (partition by dep_id order by salary asc) as min_rk from #employee) b
on a.dep_id = b.dep_id
where a.max_rk=1 and b.min_rk = 1

---

with cte as (
select dep_id, emp_name, salary,
row_number() over(partition by dep_id order by salary) as order_salary
from #employee)
select distinct dep_id,last_value(emp_name)
over(partition by dep_id order by salary range between unbounded preceding and unbounded following) 
as emp_name_max_salary,
first_value(emp_name) over(partition by dep_id order by salary) as emp_name_min_salary
from cte;

--

;with cte as (
select dep_id, min(salary) as min,max(salary) as max from #employee group by dep_id) 
,cte_max as (
select b.dep_id,b.emp_name as emp_max --, b.emp_name as emp_min 
from cte a inner join #employee b on a.dep_id = b.dep_id
where a.max = b.salary )
,cte_min as (
select b.dep_id,b.emp_name as emp_min --, b.emp_name as emp_min 
from cte a inner join #employee b on a.dep_id = b.dep_id
where a.min = b.salary )
select a.dep_id, a.emp_max, b.emp_min from cte_max a 
inner join cte_min b on a.dep_id = b.dep_id

--

with cte as (select emp_name, max(salary) over(partition by dep_id) as max_sal,
                       min(salary) over(partition by dep_id) as min_sal    
                        from #employee
)

select e.emp_name, e.salary
from #employee as e
join cte as c
on e.emp_name=c.emp_name and (e.salary=c.max_sal or e.salary=c.min_sal)
order by e.dep_id

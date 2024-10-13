

drop table if exists #emp_salary
create table #emp_salary(
    [emp_id]  INTEGER  NOT NULL,
    [name]    NVARCHAR(20)  NOT NULL,
    [salary]  NVARCHAR(30),
    [dept_id] INTEGER   );

insert into #emp_salary (emp_id, name, salary, dept_id) values
(101, 'sohan', '3000', '11'),
(102, 'rohan', '4000', '12'),
(103, 'mohan', '5000', '13'),
(104, 'cat', '3000', '11'),
(105, 'suresh', '4000', '12'),
(109, 'mahesh', '7000', '12'),
(110, 'mahesh', '17000', '12'),

(108, 'kamal', '8000', '11');

select * from #emp_salary order by dept_id ;

-- To return all employee whose salary is same in same department
-- Solution 1 Inner join 
;with sal_dep as (
select dept_id,salary from #emp_salary 
group by dept_id,salary having count(1) > 1 )
select e.* from #emp_salary e 
inner join sal_dep sd on e.dept_id = sd.dept_id and e.salary = sd.salary

-- Solution 2 Left join 
;with sal_dep as (
select dept_id,salary from #emp_salary 
group by dept_id,salary having count(1) = 1 )
select e.* from #emp_salary e 
left join sal_dep sd on e.dept_id = sd.dept_id and e.salary = sd.salary
where sd.dept_id is null

-- Solution 3
;WITH cte AS (
  SELECT *,
    COUNT(*) OVER (PARTITION BY dept_id, salary) num_same_sal
  FROM #emp_salary)

SELECT *
FROM cte
WHERE num_same_sal > 1

-- Solution 4 
select a.emp_id,a.name,a.salary,a.dept_id 
from #emp_salary a 
inner join #emp_salary b 
on a.dept_id=b.dept_id and a.emp_id<>b.emp_id 
where a.salary=b.salary
order by a.dept_id

-- Solution 5

;with cte as(select *,dense_rank() over (partition by dept_id order by salary) as rnk
from #emp_salary)

select a.emp_id,a.name,a.salary,a.dept_id 
from cte a, cte b where a.emp_id<>b.emp_id and a.dept_id=b.dept_id and a.rnk=b.rnk;

-- Solution 6

SELECT * 
FROM #emp_salary e1
WHERE EXISTS(
  SELECT 1 FROM #emp_salary e2 where e1.salary = e2.salary and e1.emp_id <> e2.emp_id
)
ORDER BY dept_id

-- Solution 7
with base as (
select dept_id,salary from #emp_salary
group by dept_id,salary having count(*) > 1)
select * from #emp_salary where dept_id in (select distinct dept_id from base) 
and salary in (select distinct salary from base)

-- Solution 8
select e1.* from #emp_salary e1  , #emp_salary e2 
where e1.salary=e2.salary and e1.dept_id=e2.dept_id and  e1.emp_id<e2.emp_id
union
select e2.* from #emp_salary e1  , #emp_salary e2 
where e1.salary=e2.salary and e1.dept_id=e2.dept_id and  e1.emp_id<e2.emp_id

-- Solution 9

--select * from #emp_salary where (dept_id,salary) IN (
--select dept_id,salary from emp_salary
--group by dept_id,salary
--having count(*) > 1 );

-- Solution 10

;with cte as (
select * , 
lead(salary) over( partition by salary, dept_id order by salary ) as rlead ,
lag(salary) over( partition by salary,dept_id order by salary ) as rlag  from #emp_salary 
)
select emp_id, name, salary  from cte where salary in (rlag, rlead)

-- Solution 11

select * from #emp_salary where concat(dept_id,salary) in
(select c from (
select concat(dept_id,salary) c,count(concat(dept_id,salary)) c1 
from #emp_salary group by concat(dept_id,salary)
having count(concat(dept_id,salary))>1) x) order by salary


-- Sol 12 

select * from #emp_salary
where salary in (select salary from #emp_salary
group by salary
having count(1) >1)
order by dept_id

-- Sol 13

with cte as (
select *,
rank() over(partition by dept_id ORDER by salary asc) as rnk
from #emp_salary
  ),
  temp_cte as (
  select *, lead(rnk,1,null) over(partition by dept_id order by salary) as next_emp_salary,
  lag(rnk,1,null) over(partition by dept_id order by salary) as prev_emp_salary
  from cte)
  
  SELECT * from temp_cte
  where next_emp_salary = rnk or prev_emp_salary = rnk

 -- Sol 14

select A.emp_id,A.name,A.dept_id,A.salary from 
(select emp_id,name,dept_id,salary,
dense_rank() over(partition by dept_id order by salary desc) as rn from #emp_salary) as A 
cross join (select emp_id,name,dept_id,salary,
dense_rank() over(partition by dept_id order by salary desc) as rn from #emp_salary) AS B
where A.dept_id=B.dept_id and A.rn=B.rn and A.emp_id!=B.emp_id order by emp_id,dept_id;

 -- Sol 15

With CTE as
(select *, 
sum(cast (salary as integer)) over(partition by  dept_id ,salary
order by dept_id ,salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED Following) s
from #emp_salary )
Select * from CTE where Salary < S
order by dept_id ,salary

-- Sol 16

select * from #emp_salary e1
where 1 <  (select count(salary) from #emp_salary e2 where e1.salary=e2.salary)
order by salary desc;



-- Sol 17
with sal_rank as(
select *, DENSE_RANK() over (partition by dept_id order by salary ) rank from #emp_salary 
),
 rank_count as(
select *, count(rank) over (partition by dept_id,rank) rank_wise_count from sal_rank
)
select emp_id,name,salary,dept_id from rank_count where rank_wise_count>1

-- Sol 18


with A as(
select *, count(0) over (partition by salary, dept_id) as instances from #emp_salary)
select * from A having instances>1 order by dept_id
--To find number of employees inside the hospital
-- 1 out  2 in , 3 in , 4 in , 5 out
drop table if exists #hospital
create table #hospital ( emp_id int, action varchar(10), time datetime);

insert into #hospital values ('1', 'in', '2019-12-22 09:00:00');
insert into #hospital values ('1', 'out', '2019-12-22 09:15:00');
insert into #hospital values ('2', 'in', '2019-12-22 09:00:00');
insert into #hospital values ('2', 'out', '2019-12-22 09:15:00');
insert into #hospital values ('2', 'in', '2019-12-22 09:30:00');
insert into #hospital values ('3', 'out', '2019-12-22 09:00:00');
insert into #hospital values ('3', 'in', '2019-12-22 09:15:00');
insert into #hospital values ('3', 'out', '2019-12-22 09:30:00');
insert into #hospital values ('3', 'in', '2019-12-22 09:45:00');
insert into #hospital values ('4', 'in', '2019-12-22 09:45:00');
insert into #hospital values ('5', 'out', '2019-12-22 09:40:00');


-- Solution 1
;with cte as (
select emp_id,
max(case when action ='in' then time end) as intime,
max(case when action ='out' then time end) as outime
from #hospital group by emp_id )

select * from cte where intime>outime or outime is null

select emp_id,
max(case when action ='in' then time end) as intime,
max(case when action ='out' then time end) as outime
from #hospital group by emp_id
having max(case when action ='in' then time end)>max(case when action ='out' then time end)
or max(case when action ='out' then time end) is null

-- Solution 2
;with intime as ( 
Select emp_id,max(time) as latest_in_time
from #hospital where action = 'in'
group by emp_id )
,outime as(
Select emp_id,max(time) as latest_out_time
from #hospital where action = 'out'
group by emp_id )
select * 
from intime i 
left join outime o on i.emp_id = o.emp_id -- to get all records from intime table
where i.latest_in_time > o.latest_out_time or o.latest_out_time is null


-- Solution 3

; with latest_time  as ( 
select emp_id,max(time) as latest_time
from #hospital group by emp_id ),
latest_in_time as (
select emp_id,max(time) as max_in_time
from #hospital where action='in'
group by emp_id  )

select *
from latest_time lt 
inner join  latest_in_time lit on lt.emp_id = lit.emp_id and
lt.latest_time = lit.max_in_time 

---

SELECT SUM(inside) from (
select count(1)%2 as inside from #hospital group by emp_id)a

-- By me
;with cte as (
select emp_id ,action,
row_number() over (partition by emp_id order by time desc) as rn
from #hospital )
select * 
from cte where rn=1 and action = 'in'


-- Solution 4

select emp_id from #hospital
where concat(emp_id, time) in 
(select concat(emp_id, max(time)) from #hospital group by emp_id) 
and action = 'in'

-- Solution 5 
;with cte as(
select *,
max(time)over(partition by emp_id) as last_entry 
from #hospital )
select emp_id,action --count(*) as total_number_present 
from cte 
where time = last_entry and action = 'in'

-- solution 6
select emp_id,action,time from
(select emp_id,action, time, case
when count(emp_id) over (partition by emp_id) = 1  then 'p' -- this is for record 4
when max(time) over (partition by emp_id) - time = 0  then 'p'
  end as rst
  from #hospital) q where rst = 'p' and action = 'in'

-- Soultion 7 great way 
select emp_id,min(time) as patients_in_hospital from(
select emp_id,action,next_action,time from(
select *,
coalesce(lead(action,1) over(partition by emp_id order by emp_id asc),'in') as next_Action 
from #hospital ) as a 
where action='in' and next_action='in') as b group by emp_id;

-- Solution 8 
;with cte as
(select emp_id, action,last_value(action) 
over (partition by emp_id ORDER BY time rows between current row and unbounded following)  
as lstvl from #hospital  )
select count(distinct emp_id) as [count] from cte where lstvl='in'

-- Solution 9

;With cte as (
Select *,
first_value(#hospital.action) OVER(partition by emp_id order by #hospital.time DESC) as Last_event
from #hospital 
) select distinct emp_id from cte where Last_event = 'in'

-- Solution 10
select *
from(select*,max(time) over (partition by emp_id)as last_time from #hospital) as A
where time = last_time and action= 'in'

-- Solution 11

select emp_id , action, time from #hospital h2 
where time = (select max(time) from #hospital h1 where h1.emp_id = h2.emp_id group by emp_id) 
and action = 'in'

-- Solution 12 only 2 rows 
;with cte as 
(select emp_id, count(*) as count_id from #hospital group by emp_id)
,temp as 
(select *, case when count_id%2=0 then 0 else 1 end as in_flag from cte) 
select * 
from temp where in_flag=0

-- Solution 13

;with cte as (
select * 
,lag(action,1,action)over(partition by emp_id order by time) as prev_ac,
count(1) over (partition by emp_id)as cnt
from #hospital)
,final as (
select *,
case when action ='in' and prev_ac='in' and cnt=1 then 1 
when action ='in' and prev_ac='out' then 1
when action ='out' and prev_ac='out' then 0 
else 0 end as flag
from cte)

select distinct emp_id from final where flag=1

-- Solution 14 with max value

;with cte as
(select *,
row_number() over(partition by emp_id order by emp_id) as rw 
from #hospital
)
,cte2 as (
select *, 
max(rw) over(partition by emp_id order by emp_id ) as max_val
from cte
)
select emp_id,action,time from cte2
where rw = max_val and action like 'in';

-- Solution 15

select b.emp_id,b.action,b.time from
(select emp_id,max(time)max_time
from #hospital 
group by emp_id )a
inner join #hospital b on a.emp_id=b.emp_id and a.max_time=b.time
where b.action='in'

-- Solution 16 

;with cte as (select *,case when action = 'out' then 0
when action = 'in' then 1 end as total ,
row_number() over(partition by emp_id order by time desc) as rnk from #hospital)
select * from cte where rnk=1 and total =1;
--Select sum(total) from cte where rnk=1;


-- Solution 17 not for SQL server
/*
select 
    emp_id as emp_inside
from #hospital
where (emp_id, time) in (select emp_id, max(time) as last_action_time from #hospital group by emp_id)
and action = 'in';
*/

-- Solution 18

with cte as (
select *,lead(action,1) over (partition by emp_id order by time ) as nextaction from #hospital
  )select emp_id, action from cte where nextaction is null and action = 'in'

-- Solution 19 
with base as(
select *,
last_value(action) over(partition by emp_id order by emp_id ) as curr_flag
from #hospital) ,base1 as(
select * from base where curr_flag='in') 
select  distinct emp_id as no_of_employees from base1

-- Solution 20

;with cte as (
select *, max(time) over (partition by emp_id) as max_time
from #hospital
)
select emp_id,action,time from cte where time = max_time and action = 'in';


-- Solution 21 
;with cte as
(select emp_id, action, lead(action,1,action) over 
  (partition by emp_id order by time)lead_value 
      from #hospital)

select emp_id
--count(case when lead_value = action and action = 'in' and lead_value = 'in' then 1 end) 
--as total_no_of_people
from cte
where lead_value = action and action = 'in' and lead_value = 'in'
group by emp_id


-- Solution 22

;with cte as (select *, max(time) over(partition by emp_id) as last_time from #hospital)
select count(emp_id) from cte where time=last_time and action='in';

-- Sol 23

with cte as(select DISTINCT * from 
(select *, Lead(action ,1) over(partition by emp_id order by time) as second ,
Lead(time,1) over(partition by emp_id order by time) as out_time 
from #hospital ) as a 
where action = 'in' 
)

select count(emp_id) as 'total number of emp inside' from cte where second is null


-- Sol 24

with temp as (
select emp_id
from #hospital
group by emp_id
having sum(case when action = 'in' then 1 else 0 end) > sum(case when action='out' then 1 else 0 end)
)
select count(emp_id) from temp

-- Sol 25

; WITH all_actions as(
SELECT emp_id,RIGHT((string_agg(action,',')),3)AS all_actions
FROM #hospital
GROUP BY emp_id)
SELECT emp_id
FROM all_actions WHERE all_actions IN('in',',in')

-- Sol 26

; With cte as 
(
Select 
		distinct
		emp_id,
        last_value(action) Over(partition by emp_id Order by time asc Range between Unbounded preceding and unbounded Following) as lval
From 
	#hospital
 )
 
 Select 
		Sum(case when lval='in'  Then 1 Else 0 End) as Total_inside
FROm 
	cte

--

; With temp as (Select emp_id, Case when action='in' then 1 else -1 end act
From #hospital)
Select emp_id from temp
Group by emp_id
Having sum(act) > 0


-- Sol 27

with cte as
(select *,
ROW_NUMBER() over(partition by emp_id order by time desc) as ranking
from #hospital)

select emp_id 
from cte
where Ranking = 1 and CONCAT(action,ranking) not in ('out1')


-- Sol 28
-- PIVOT function

select * from
(
select * from #hospital
) a
pivot(
      Max(Time) for action in ([in] , [out] )
    ) b 
 where b.[in]>out or out is null

 -- Sol 29

 with cte as
(
select *,
row_number() over(partition by emp_id order by time asc) as rnk
from #hospital
)
,cte1 as 
(
select emp_id,max(rnk) as max_rnk from cte 
group by emp_id
)
select cte.emp_id
from cte inner join cte1
on cte.emp_id=cte1.emp_id and cte.rnk=cte1.max_rnk
where action='in'

--
select emp_id,action,max(time)
from #hospital
group by emp_id
having action='in'

-- 
SELECT COALESCE(SUM(CASE action WHEN 'in' THEN 1 WHEN 'out' THEN -1 ELSE 0 END), 0)
AS num_employees_inside FROM #hospital;


--

;with cte as (
select emp_id, 
case when action = 'in' then time end as login_time ,
case when action = 'out' then time end as logout_time 
from  #hospital),
cte2 as(
select *, 
coalesce(login_time, lead(login_time) over(partition by emp_id order by emp_id)) as login_time_,
coalesce(logout_time, lead(logout_time) over(partition by emp_id order by emp_id)) as logout_time_ from cte)
select * from cte2
where logout_time_ is null;

--

--I thought the problem was to calculate number of people in the hospital at each time so i wrote a different code for that:

;with cumulative as 
(
with final as
(
with time_cte as 
(select *, row_number() over(partition by emp_id order by time) as drn from #hospital)
select time, sum(
 case when drn=1 and action='out' then 0
 when action='in' then 1
 when action='out' then -1
 end)
 over(partition by time) as time_sum from time_cte order by time)
 select time, time_sum from final group by time)
 select time, sum(time_sum) over(order by time) number_in_hospital from cumulative;

 /*
The result was consistent with your solution (3 people left at the end with emp_ids 2,3,4). 3,5 were already inside the hospital initially and that has to be taken care of.
2019-12-22 09:00:00	2
2019-12-22 09:15:00	1
2019-12-22 09:30:00	1
2019-12-22 09:40:00	1
2019-12-22 09:45:00	3 */


--

Select emp_id as IN_Employee,TIN as IN_TIME from 
(
select emp_id,action,TIN,row_number() over (partition by emp_id order by TIN desc ) as rn from
(
select emp_id,action,max(time) as TIN from #hospital 
where action='in'
group by emp_id,action
UNION ALL
select emp_id,action,max(time) as TOUT from #hospital 
where action='out'
group by emp_id,action) A

)B 
where action='in' AND rn=1

--
with cte as (
select *,
last_value(action = 'in') over(partition by emp_id) as login from #hospital
order by emp_id, time)
select emp_id from cte
where login =1
group by emp_id; 


--

@akashdeep5088
1 year ago
Below is my solution for the given problem 
I have solved it on Microsoft SQL Server, so if anyone opening in any other RDMS please edit the code as per the need 
The code is lengthy but will given a proper solution with status of all the employee even if they are out 


select emp_id,
case when max_emp_time>max_out then 'present'
else 'not present'
end as 'status'
from (
select a.emp_id,isnull(b.action,'in')action,a.max_emp_time,isnull(b.max_out,0)max_out
from(
select distinct emp_id,
max(time)over(partition by emp_id)max_emp_time
from hospital
)a
full outer join (
select distinct emp_id,action,
max(time)over(partition by emp_id,action)max_out 
from hospital
where action like 'out')b
on a.emp_id=b.emp_id) A


---

select a.emp_id, sum(a.status) as final_status from (
select emp_id, 
case
when action='in' then 1
when action='out' then -1 else 0 end as status from #hospital) a
group by a.emp_id
having sum(a.status) >=1






--
select count(emp_id) from
  (
  select emp_id,max(time)
  from #hospital
  group by emp_id
  having  action = 'in') subq;

  --

  with emp_last_action as
         (select emp_id, max(time) as last_action_time
          from hospital
          group by emp_id
          order by emp_id)

select emp_last_action.emp_id
from emp_last_action
join #hospital on emp_last_action.emp_id = hospital.emp_id AND emp_last_action.last_action_time = hospital.time
where hospital.action = 'in';
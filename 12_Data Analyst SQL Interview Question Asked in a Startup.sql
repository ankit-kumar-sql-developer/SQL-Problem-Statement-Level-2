

create table #call_start_logs
(
phone_number varchar(10),
start_time datetime
);
insert into #call_start_logs values
('PN1','2022-01-01 10:20:00'),('PN1','2022-01-01 16:25:00'),('PN2','2022-01-01 12:30:00')
,('PN3','2022-01-02 10:00:00'),('PN3','2022-01-02 12:30:00'),('PN3','2022-01-03 09:20:00')

create table #call_end_logs
(
phone_number varchar(10),
end_time datetime
);
insert into #call_end_logs values
('PN1','2022-01-01 10:45:00'),('PN1','2022-01-01 17:05:00'),('PN2','2022-01-01 12:55:00')
,('PN3','2022-01-02 10:20:00'),('PN3','2022-01-02 12:50:00'),('PN3','2022-01-03 09:40:00')
;

/*write a query to get start time and end time of each call from below 2 tables.A1so create a column of call
duration in minutes. Please do take into account that there will be multiple calls from one phone number
and each entry in start table has a corresponding entry in end table.*/


-- Sol 1 Join
select a.phone_number,a.start_time,b.end_time, 
datediff(minute,start_time,end_time) as call_time from 
(select *, row_number() over(partition by phone_number order by start_time ) as rn
from #call_start_logs ) a
inner join 
(select *, row_number() over(partition by phone_number order by end_time ) as rn
from #call_end_logs ) b  on a.phone_number = b.phone_number and a.rn= b.rn

-- Sol 2 Union All 
select phone_number,min(call_time) as Start_time,max(call_time) as end_time, 
datediff(minute,min(call_time),max(call_time)) as call_duration  from 
(select phone_number,start_time as call_time,
row_number() over(partition by phone_number order by start_time ) as rn
from #call_start_logs 
union all  
select phone_number,end_time as call_time, 
row_number() over(partition by phone_number order by end_time ) as rn
from #call_end_logs ) A group by phone_number,rn

--

;with cte as(
select s.phone_number,s.start_time,e.end_time,lag(e.end_time) 
over(partition by s.phone_number order by end_time,start_time desc) as last_call_time
from #call_start_logs s inner join #call_end_logs e
on s.phone_number = e.phone_number and start_time < end_time
)
select phone_number,start_time,end_time,
datediff(minute,start_time,end_time)
from cte
where end_time<>last_call_time or last_call_time is null;

--

;with ct1 as (
select *, row_number() over(order by (select null)) as rn from #call_start_logs)
,ct2 as (
select *, row_number() over(order by (select null)) as rn from #call_end_logs)
select s.phone_number, start_time, end_time,
datediff(minute,start_time, end_time) as duration 
from ct1 s join ct2 e on s.rn = e.rn
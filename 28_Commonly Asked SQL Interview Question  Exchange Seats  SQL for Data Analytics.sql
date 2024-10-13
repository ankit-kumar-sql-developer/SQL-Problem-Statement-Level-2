
drop table if exists #seats
create table #seats (
    id int,
    student varchar(10)
);

insert into #seats values 
(1, 'amit'),
(2, 'deepa'),
(3, 'rohit'),
(4, 'anjali'),
(5, 'neha'),
(6, 'sanjay'),
(7, 'priya');

--To swap / exchange consecutive seats of students. 
--if no of students is odd, last id students wont be swapped

-- Sol 1
select *,
case when id = ( select max(id) from  #seats) and id %2 =1 then id
     when id%2=0 then id-1 else id+1 end as new_id
from #seats

-- Sol 2 not consecutive -- use row_number
select *,
case when id%2=0 then lag(id,1) over (order by id)  
else lead(id,1,id) over (order by id)  end as new_id
from #seats

-- update
Update #seats
set #seats.id = new_seats.new_id
from (select *,
case when id%2=0 then lag(id,1) over (order by id)  
else lead(id,1,id) over (order by id)  end as new_id
from #seats) new_seats
where #seats.id= new_seats.id

SElect * from #seats

--
select id,
case 
  when id%2=0 then lag(student, 1) over(order by id)
  when id%2!=0 then coalesce(lead(student, 1) over(order by id), student)
  end as swapped_seats
from #seats;
--
;with cte as (select *,
lead(student) over(partition by null) as lead,
lag(student) over(partition by null) as lag
from #seats)
select id,case when id%2 <> 0 then coalesce(lead, student)
else lag end as alternate_seats
from cte

--
declare @count int
set @count = (select case when COUNT(*)%2 = 0 then COUNT(*)
else COUNT(*) + 1 end from #seats);

update #seats
set student = [regrouped students]
from (select id,
case when coalesce(LEAD(student, 1) over(partition by [group] order by [row num]),
LAG(student, 1) over(partition by [group] order by [row num])) is null
then student 
else coalesce(LEAD(student, 1) over(partition by [group] order by [row num]),
LAG(student, 1) over(partition by [group] order by [row num]))end [regrouped students]
from (select *,
NTILE(8/2) over(order by [row num]) [group]
from (select ROW_NUMBER() over(order by (select 1)) [row num], *
from #seats) s1) s2) s3
where #seats.id = s3.id;




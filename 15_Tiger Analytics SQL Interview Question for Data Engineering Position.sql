
create table #family 
(
person varchar(5),
type varchar(10),
age int
);
delete from #family ;
insert into #family values ('A1','Adult',54)
,('A2','Adult',53),('A3','Adult',52),('A4','Adult',58),('A5','Adult',54),('C1','Child',20),('C2','Child',19),('C3','Child',22),('C4','Child',15);

-- Adults are more than child

;with cte_adult as (
select *, row_number() over (order by person) as rn
from #family where type='adult' )
,cte_child  as (
select *, row_number() over (order by person) as rn
from #family where type='child')

Select a.person,IsNull(b.person,'NA') as person from cte_adult a
left join cte_child b on a.rn = b.rn 

-- Twist Eldest adult go with youngest child
;with cte_adult as (
select *, row_number() over (order by age desc) as rn
from #family where type='adult' )
,cte_child  as (
select *, row_number() over (order by age asc) as rn
from #family where type='child')
Select a.person,IsNull(b.person,'NA') as person ,a.age,b.age from cte_adult a
left join cte_child b on a.rn = b.rn 

-- 
select a.person , c.person from (
select *,right(person , 1) as a_id from #family  where type = 'adult' )  as a 
left join 
(select *,right(person , 1) as c_id from #family where type = 'child') as c 
on a.a_id= c.c_id 

--
with cte1 as(select *,right(person,1) as p1 from #family)
select string_agg(person,'') within group (order by person asc) as pair from cte1
group by p1;

--
select max(case when type = 'Adult' then person end) as p 
,max(case when type = 'Child' then person end ) as c from  
(select * , row_number() over(partition by type order by age desc ) as r
from #family ) as a  group by r  ;

;with cte as(select *,
row_number()over(partition by type order by person) as rw
from #family)
select 
max(case when type ='adult' then person end) as adult,
max(case when type = 'child' then person end) as child
from cte
group by rw;
--

with cte as(
select *, row_number() over(partition by type order by 
(case when type='Child' then age else -1 * age end)) rn from #family )
select string_agg(person, ' ') within group(order by person)
from cte group by rn

--
;with cte as(
select *,row_number() over(partition by type order by person) as rn
from #family)
select a.*,b.* from cte a left join cte b On a.rn=b.rn

-- Recursive CTE 
;with recursive_cte as (
  select person, type, row_number() over(Order by type) as p1 from #family
  where type='Adult'
union all
  select person, type, row_number() over(Order by type) as p1 from #family
  where type = 'Child'
)
select string_agg(person,',') as person, string_agg(type,' ,') as type from recursive_cte
group by p1

--VVI
;with cte_1 as (
select type,count(person) as pp from #family group by type)
select * from(
select f.*,lead(f.person,pp) over(order by f.type)as child,pp from #family f
join cte_1 on cte_1.type=f.type)x
where x.type='child';
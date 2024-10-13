

create table #city_population (
    state varchar(50),
    city varchar(50),
    population int
);

-- insert the data
insert into #city_population (state, city, population) values ('haryana', 'ambala', 100);
insert into #city_population (state, city, population) values ('haryana', 'panipat', 200);
insert into #city_population (state, city, population) values ('haryana', 'gurgaon', 300);
insert into #city_population (state, city, population) values ('punjab', 'amritsar', 150);
insert into #city_population (state, city, population) values ('punjab', 'ludhiana', 400);
insert into #city_population (state, city, population) values ('punjab', 'jalandhar', 250);
insert into #city_population (state, city, population) values ('maharashtra', 'mumbai', 1000);
insert into #city_population (state, city, population) values ('maharashtra', 'pune', 600);
insert into #city_population (state, city, population) values ('maharashtra', 'nagpur', 300);
insert into #city_population (state, city, population) values ('karnataka', 'bangalore', 900);
insert into #city_population (state, city, population) values ('karnataka', 'mysore', 400);
insert into #city_population (state, city, population) values ('karnataka', 'mangalore', 200);

select * from #city_population

-- Sol 1
;with cte as (
select *,
max(population) over(partition by state) as max_population,
min(population) over(partition by state) as min_population
from #city_population )
select state,
MAX(case when max_population= population then city else null end) as highest,
MIN(case when min_population= population then city else null end) as highest
from cte group by state
-- Sol 2
; with cte as (
select *,
row_number() over(partition by state order by population desc) as rn_desc,
row_number() over(partition by state order by population ) as rn_asc
from #city_population )
select state,
MAX(case when rn_desc= 1 then city else null end) as highest,
MIN(case when rn_asc= 1 then city else null end) as highest
from cte group by state



--
;with cte as (
select state, max(population) as max , min(population) as min
from #city_population group by state )
select cp.state,
max(case when max= population then city else null end) as max1,
max(case when min= population then city else null end) as max2
from #city_population cp inner join cte on cp.state= cte.state
group by cp.state

--
;with cte as (
select *,
FIRST_VALUE(city) over(partition by state order by population desc) as max_popln_city,
FIRST_VALUE(city) over(partition by state order by population asc) as min_popln_city
from #city_population
)
select state,min(max_popln_city) as highest_populated_city,min(min_popln_city) as lowest_populated_city  
from cte group by state;

--
select distinct state,
first_Value(city)over(partition by state order by population) as Lowest_Populated_City,
last_Value(city)over(partition by state order by population rows between unbounded preceding and unbounded following) as Highest_Populated_City
from #city_population;

--

with cte1 as(
select state,city as max_populated from #city_population c2 
where population=(select max(population) from #city_population c1 where c1.state=c2.state)
),
cte2 as(
select state,city as min_populated from #city_population c2
where population=(select min(population) from #city_population c1 where c1.state=c2.state)
)
select a.*,b. min_populated from cte2 b join cte1 a on a.state=b.state

--
select state,
(select Top 1 city from #city_population cp1 where cp1.state = cp.state order by population desc ) as city_max_population,
(select Top 1 city from #city_population cp2 where cp2.state = cp.state order by population asc ) as city_min_population
from  #city_population cp
group by  state;

--
with cte as
(
select state,city,population,
population - lag(population,1,population)over(partition by state order by population) as mi,
population - lead(population,1,population)over(partition by state order by population) as ma
from #city_population) 
select state,
max(case when ma = 0 then city else null end) as max_population_city,
min(case when mi = 0 then city else null end) as min_population_city 
from cte group by state
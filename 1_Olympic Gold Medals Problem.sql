
 -- to find player with no of gold medals won by them only for players who won only gold medals

drop table if exists #events
create table #events (
ID int,
event varchar(255),
YEAR INt,
GOLD varchar(255),
SILVER varchar(255),
BRONZE varchar(255)
);

delete from #events;

INSERT INTO #events VALUES (1,'100m',2016, 'Amthhew Mcgarray','donald','barbara');
INSERT INTO #events VALUES (2,'200m',2016, 'Nichole','Alvaro Eaton','janet Smith');
INSERT INTO #events VALUES (3,'500m',2016, 'Charles','Nichole','Susana');
INSERT INTO #events VALUES (4,'100m',2016, 'Ronald','maria','paula');
INSERT INTO #events VALUES (5,'200m',2016, 'Alfred','carol','Steven');
INSERT INTO #events VALUES (6,'500m',2016, 'Nichole','Alfred','Brandon');
INSERT INTO #events VALUES (7,'100m',2016, 'Charles','Dennis','Susana');
INSERT INTO #events VALUES (8,'200m',2016, 'Thomas','Dawn','catherine');
INSERT INTO #events VALUES (9,'500m',2016, 'Thomas','Dennis','paula');
INSERT INTO #events VALUES (10,'100m',2016, 'Charles','Dennis','Susana');
INSERT INTO #events VALUES (11,'200m',2016, 'jessica','Donald','Stefeney');
INSERT INTO #events VALUES (12,'500m',2016,'Thomas','Steven','Catherine');

Select * from #events Order by event
Select distinct gold from #events Order by event

-- Sub Query

select gold as player_name, count(1) as no_of_medal
from #events
where gold not in ( 
select silver from #events
union all
select bronze from #events)
group by gold

--or 
select gold as playername,count(1) as noofmedals 
from #events group by gold 
having gold not in (select silver from #events union all select bronze from #events)


-- Group by having cte

;with cte as (
select gold as player_name,'gold' as medal_type from #events
union all
select silver,'silver' as medal_type from #events
union all
select bronze,'bronze' as medal_type from #events )

Select player_name, count(1) as no_of_gold_medal
from cte 
group by player_name
--having medal_type  in (Gold 1)
having count(distinct medal_type)=1 and max(medal_type) = 'Gold'

-- select count(medal_type), count(distinct medal_type), min(medal_type) from cte

-- Solution 3

;With cte as (
Select GOLD AS G, Count(*) AS C1 From #events Group by GOLD ),
cte1 as (
Select SILVER AS S from #events group by SILVER ),
cte2 as (
Select BRONZE AS B from #events group by BRONZE )

Select * from cte 
Where G NOT IN (Select S from cte1 UNION ALL Select B from cte2)

-- Solution 4

select gold as name,
count(*) as total
from #events where gold not in (select silver from #events group by silver)
and gold not in (select bronze from #events group by bronze)
group by gold
order by gold;

-- Solution 5 co related sub query 

select gold,count(*) from  
 (select e1.gold from #events e1 where not
  exists(select 1 from #events e2 where e1.gold=e2.silver or e1.gold=e2.bronze))a
  group by gold;


-- Solution 6
-- left join matching record means player having both medals 
select * from (
select count(id) as cg,gold as swimmernameg from #events group by gold ) a
left join (
select count(id) as cs,silver as swimmernames from #events group by silver) b 
on a.swimmernameg = b.swimmernames 
left join (
select count(id) as cb,bronze as swimmernameb from #events group by bronze ) c 
on a.swimmernameg = c.swimmernameb 
where swimmernames is null and swimmernameb is null

-- Solution 7

select  distinct gold, count(*) over(partition by gold) from #events
where gold not in (select silver from #events union all select bronze from #events)


-- Solution 8

with N as (select Gold 
from #events
where Gold not in (select SILVER from #events ) 
)
,
M as (select Gold 
from N 
where Gold not in ( select Bronze from #events)
)
select Gold , count(1)as no_of_gold_win
from M 
group by Gold

--- Solution 9
-- Only PlayerName 
; with cte as (
select gold from #events
except
select silver as gold from #events
except
select bronze as gold from #events )
select gold as player_name
from cte group by gold

--- Solution 10 Left join

; With cte as
(
Select a.id, a.event, a.year, a.gold, b.silver, c.bronze
from #events a LEFT JOIN #events b ON  lower(a.gold) = lower(b.silver)
LEFT JOIN #events c ON lower(a.gold) = lower(c.bronze)
),
cte1 as
( Select distinct id, event, year, gold, silver, bronze
  from cte where silver is null and bronze is null
)
Select gold, COUNT(id) from cte1 group by 1

--- Solution 11 Left join

select e.Gold,count(e.Gold) NoOfTimesWonGold from #events e
left join #events s on e.Gold = s.Silver
left join #events b on e.Gold = b.bronze
where s.Silver is null and b.bronze is null
group by e.Gold

-- Solution 12

 ;WITH cte AS (SELECT silver AS swimmer FROM #EVENTS UNION ALL
SELECT bronze AS swimmer FROM #EVENTS
)
SELECT gold,COUNT(1) FROM #EVENTS WHERE gold NOT IN (SELECT *  FROM cte) GROUP BY gold

-- Solution 13 
select a.gold, count(a.gold) from #events a 
left join #events b on a.gold=b.silver or a.gold=b.bronze 
where b.silver is null group by a.gold


-- Solution 14

-- CTE 1 : Combine 3 separate columns into a single column (keeping duplicate values ​​intact)-- 
; with CTE_A as 
(select 
GOLD as player_name, 'gold' as type_of_medal -- create a new column
from #events
union all
select
SILVER as player_name,	'silver' as type_of_medal -- create a new column
from #events
union all
select 
BRONZE as player_name, 'bronze' as type_of_medal -- create a new column
from #events --order by player_name, type_of_medal
)

-- CTE 2: After arranging the first and last names and medal types in alphabetical order, find the first and last medal types of each athlete. --
,CTE_B as ( 
select *,
first_value(type_of_medal) over (partition by player_name order by type_of_medal ) as fiva,
last_value(type_of_medal) over (partition by player_name order by type_of_medal  
RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as lava
from CTE_A)

select 
player_name,
count(type_of_medal) as no_of_gold
from CTE_B
where fiva = lava and type_of_medal in ('gold')
group by player_name;

-- Solution 15

With c as (
select *,
case When  GOLD in (select SILVER from #events) or GOLD in (select BRONZE from #events)   
then 1 else 0 end  as dupl from #events )
select Gold ,count (Gold)  from c  where dupl = 0 group by Gold ;

-- Solution 16

select gold,count(*) 
from #events
where gold not in (select silver from #events) and gold not in (select bronze from #events)
group by gold; 
--order by event

select *, count(*) 
from #events
where gold not in (silver) and gold not in (bronze)
group by gold;
--order by event

-- Solution 17

select medal_holder,medal_category_count
from (
select medal_holder,medal_type,medal_category_count,
count(*) over (partition by medal_holder order by medal_category_count asc) as cnt
from(
select medal_holder,medal_type,count(*) as medal_category_count from 
(
select Gold as medal_holder ,'gold' as medal_type from #events
union all
select silver ,'silver' as medal_type from #events
union all
select bronze ,'bronze' as medal_type from #events
) A
group by medal_holder,medal_type
--order by medal_holder 
) B
) C
where cnt = 1 and medal_type='gold'

-- Solution 18

;with cte as (
	Select gold as swimmer, 'gold' as category from #events
	union all
	Select silver as swimmer, 'silver' as category from #events
	union all
	Select bronze as swimmer, 'bronze' as category from #events
)
Select swimmer, sum(case when category='gold' then 1 else 0 end ) as gold_medal_counts,
count(1) as total_medal_counts
from cte
group by swimmer
having sum(case when category='gold' then 1 else 0 end ) = count(1)
order by 1


-- Solution 19

SELECT GOLD AS PLAYERNAME, COUNT(1) AS NO_OF_GOLDMEDALS
FROM #EVENTS GROUP BY GOLD
HAVING GOLD NOT IN(
SELECT SILVER FROM #EVENTS
UNION ALL
SELECT BRONZE FROM #EVENTS)

--

SELECT GOLD,COUNT(*) as no_of_gold
FROM #events
where GOLD IN (
               SELECT DISTINCT(GOLD) from #events
               where GOLD not in (select SILVER from #events) AND GOLD not in (select BRONZE from #events)
			  )
group by GOLD;

--

select count(1) as no_of_gold, GOLD as Player
from #events
where gold not in (select silver from #events where silver not in (select bronze from #events group by bronze) group by silver)
group by gold; 

--

;WITH only_gold AS (
	select gold AS player from #events
	EXCEPT
	select silver AS player from #events
	EXCEPT
	select bronze AS player from #events
	--order by 1
)
select 
	 gold
	,count(id)
from
	#events e
JOIN only_gold g ON (g.player = e.gold)
GROUP BY gold
ORDER BY gold; 
create table #icc_world_cup
(
match_no int,
team_1 varchar(20),
team_2 varchar(20),
winner varchar(20)
);
insert into #icc_world_cup values(1,'eng','nz','nz');
insert into #icc_world_cup values(2,'pak','ned','pak');
insert into #icc_world_cup values(3,'afg','ban','ban');
insert into #icc_world_cup values(4,'sa','sl','sa');
insert into #icc_world_cup values(5,'aus','ind','ind');
insert into #icc_world_cup values(6,'nz','ned','nz');
insert into #icc_world_cup values(7,'eng','ban','eng');
insert into #icc_world_cup values(8,'sl','pak','pak');
insert into #icc_world_cup values(9,'afg','ind','ind');
insert into #icc_world_cup values(10,'sa','aus','sa');
insert into #icc_world_cup values(11,'ban','nz','nz');
insert into #icc_world_cup values(12,'pak','ind','ind');
insert into #icc_world_cup values(12,'sa','ind','draw');


select * from #icc_world_cup


; with all_matches as (
Select team, Sum(no_of_matches_played) as no_of_matches_played from (
select  team_1 as team, count(*)  as no_of_matches_played from #icc_world_cup group by team_1 
union  all
select  team_2 as team, count(*) as no_of_matches_played from #icc_world_cup group by team_2 ) a
group by team )
,winner as (
Select winner, count(*) as wins from #icc_world_cup group by winner )

select m.team,m.no_of_matches_played,coalesce(w.wins,0) as wins,
m.no_of_matches_played -coalesce(w.wins,0) as loss,coalesce(w.wins,0)*2 as pts
from all_matches m
left join winner w on m.team = w.winner order by pts desc, loss desc


-- Solution 2

; with all_matches as (
Select team, Sum(no_of_matches_played) as no_of_matches_played, Sum(win_flag) as wins,
Sum(NR) as Not_result
from (
select  team_1 as team, count(*)  as no_of_matches_played,
sum(case when team_1= winner then 1 else 0 end ) as win_flag,
sum(case when winner= 'draw' then 1  else 0 end ) as NR
from #icc_world_cup group by team_1 
union  all
select  team_2 as team, count(*) as no_of_matches_played,
sum(case when team_2= winner then 1 else 0 end ) as win_flag,
sum(case when winner= 'draw' then 1  else 0 end ) as NR
from #icc_world_cup group by team_2 ) a
group by team )

select *, (no_of_matches_played - wins- Not_result) as loss, 
(wins*2) + (Not_result*1)   as pts
from all_matches order by wins desc 


--

with match as 
(
SELECT team_1 as team,winner from #icc_world_cup iwc 
union all
SELECT team_2 as team,winner from #icc_world_cup iwc 
)
select team,count(team) Matchs_played,
sum(case when team = winner then 1 else 0 end ) Win,
sum(case when winner is null then 1 else 0 end ) Draw,
sum(case when team != winner then 1 else 0 end ) lost,
sum(case when team = winner then 1 else 0 end) * 2 Points
from match
group by team
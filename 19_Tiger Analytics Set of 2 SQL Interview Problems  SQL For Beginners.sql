
--problem 1:
drop table if exists #flights
create table #flights 
(
    cid varchar(512),
    fid varchar(512),
    origin varchar(512),
    destination varchar(512)
);

insert into #flights (cid, fid, origin, destination) values ('1', 'f1', 'del', 'hyd');
insert into #flights (cid, fid, origin, destination) values ('1', 'f2', 'hyd', 'blr');
insert into #flights (cid, fid, origin, destination) values ('2', 'f3', 'mum', 'agra');
insert into #flights (cid, fid, origin, destination) values ('2', 'f4', 'agra', 'kol');

select * from #flights

--insert into #flights (cid, fid, origin, destination) values ('1', 'f3', 'blr', 'mom');

-- Problem 1

Select o.cid,o.origin, d.destination
from #flights o
inner join #flights d on o.destination = d.origin -- vvi

--
; with cte as (
select * ,lead(destination) over (partition by cid order by fid) as dest
from #flights )
select cid,origin, dest as dest from cte where dest is not null

-- epic
Select f1.cid,f1.origin, f2.destination 
from #flights f1 cross join  #flights f2 
where f1.cid = f2.cid and f1.destination = f2.origin

/*
Select *  
from #flights f1 cross join  #flights f2  where f1.cid=1 and f2.cid=1 order by f1.fid
where f1.cid = f2.cid and f1.destination = f2.origin 

*/
--
select distinct cid, first_value(origin) over(partition by cid order by fid ) as actual_origin,
first_value(Destination) over(partition by cid order by fid desc) as final_destination
from #flights

--
select distinct cid, first_value(origin) over(partition by cid order by fid rows between unbounded preceding and unbounded following) as actual_origin,
last_value(destination) over(partition by cid order by fid rows between unbounded preceding and unbounded following) as final_destination
from #flights


--
;with cte1 as (
select *,
row_number() over (partition by cid order by fid) as rk_origin,
row_number() over (partition by cid order by fid desc) as rk_dest 
from #flights )  
select 
c1.cid, c1.origin as first_origin, c2.destination as last_destination
from cte1 c1 
join cte1 c2 on c1.cid = c2.cid 
where c1.rk_origin = 1 and c2.rk_dest = 1;


--

with cte as (
	select *,
	rank() over (partition by cid order by fid) as rnk
	from #flights
)
select cid,
	max(case when rnk=1 then origin end) as origin,
	max(case when rnk=2 then Destination end) as destination
from cte
group by cid


--
;with cte as(
select cid ,origin as loc ,'start_loc' as column_name from #flights 
union all
select cid ,destination as  loc ,'end_loc' as column_name  from #flights ),
cte2 as(
select *,count(*) over(partition by cid,loc) as cnt from cte )
select cid ,
max(case when column_name = 'start_loc' then loc end )as origin,
max(case when column_name = 'end_loc ' then loc end) as destination
from cte2 where cnt=1 group by cid

-- 3 stops

;with flight as( 
select *,count(*) over(partition by cid) totalflights, 
row_number() over(partition by cid order by fid )as flightNumber from #flights )
, flight2 as (
select cid, case when flightNumber=1 then origin end as origin,
case when flightNumber=totalflights then destination end as destination
from flight )

select cid,MAX(origin) as origin,max(destination) as destination 
from flight2 group by cid

-- 
;with cte as (
select cid, origin, Destination, Rank() over (partition by cid order by fid) as rnk
from #flights),
cte1 as (
select cid, origin, Destination, Rank() over (partition by cid order by fid Desc) as rnk
from #flights),
cte2 as (
select c1.cid, c1.origin, c2.Destination
from cte c1 inner join cte1 c2 on c1.cid=c2.cid
where c1.rnk=1 and c2.rnk=1)
select * from cte2;


--
select cid, origin, final_dest from (
Select  *, 
lead(origin) over(partition by cid order by cid) as transit_source,
lead(destination) over(partition by cid order by cid) as final_dest
from #flights)i  where destination=transit_source


--
with t1 as (
select *, lag(Destination,1) OVER ( partition by cid ORDER BY cid) AS Destination1,
lag(origin,1) OVER ( partition by cid ORDER BY cid) AS origin1 from #flights
)
SELECT cid,origin1,Destination from t1 where origin = Destination1;

-- Problem : flight more than 2 stops

insert into #flights (cid, fid, origin, destination) values ('1', 'f3', 'blr', 'mom');

with tab as (
select *,lag(origin) over (partition by cid order by (select null)) prev_origin,
lead(Destination) over (partition by cid order by (select null)) nxt_des from #flights )
select cid,max(case when prev_origin is null then origin end) as ori,
max(case when nxt_des is null then Destination end) as Dest from tab
group by cid


;with cte1 as
(
select cid,origin from #flights 
except
select cid,destination as origin from #flights 
),cte2 as
(select cid,destination from #flights 
except
select cid,origin as destination from #flights
) 
select c1.cid,c1.origin,c2.destination from cte1 c1
inner join cte2 c2 on c1.cid = c2.cid








--

INSERT INTO flights (cid, fid, origin, Destination) VALUES ('1', 'f1', 'Del', 'Hyd');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('1', 'f2', 'Hyd', 'Blr');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('2', 'f3', 'Mum', 'Agra');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('2', 'f4', 'Agra', 'Kol');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('2', 'f5', 'Kol', 'Chen');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('3', 'f6', 'Chen', 'Blr');


Solution:
with cte1 as(
select cid,fid,origin,destination,
row_number() over(partition by cid order by fid) as rn_o,
row_number() over(partition by cid order by fid desc) as rn_d  from flights
) 
,cte2 as (
select c1.cid, 
case when c1.rn_o = 1 then c1.origin end as origin, 
case when c2.rn_d = 1 then c2.destination end as destination 
    from cte1 c1 join cte1 c2 on c1.cid = c2.cid where c1.origin is not null and c2.destination is not null )
select * from cte2 where origin is not null and destination is not null;
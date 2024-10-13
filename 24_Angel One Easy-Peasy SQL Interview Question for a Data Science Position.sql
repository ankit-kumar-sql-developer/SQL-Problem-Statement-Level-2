
create table #tickets (
    airline_number varchar(10),
    origin varchar(3),
    destination varchar(3),
    oneway_round char(1),
    ticket_count int
);


insert into #tickets (airline_number, origin, destination, oneway_round, ticket_count)
values
    ('def456', 'bom', 'del', 'o', 150),
    ('ghi789', 'del', 'bom', 'r', 50),
    ('jkl012', 'bom', 'del', 'r', 75),
    ('mno345', 'del', 'nyc', 'o', 200),
    ('pqr678', 'nyc', 'del', 'o', 180),
    ('stu901', 'nyc', 'del', 'r', 60),
    ('abc123', 'del', 'bom', 'o', 100),
    ('vwx234', 'del', 'nyc', 'r', 90);


	Select * from #tickets
/*write a query to find busiest route along with total ticket count
oneway round = 'O' -> One Way Trip
oneway round = 'R' -> Round Trip
Note :DEL - > BOM is different route from BOM -> DEL*/

-- For only one way
select origin,destination,sum(ticket_count) as tc 
from #tickets group by origin,destination

--
select origin,destination,sum(ticket_count) as tc from (
select origin,destination,ticket_count
from #tickets 
union all
select destination,origin,ticket_count
from #tickets where oneway_round='r' ) a
group by origin,destination order by tc desc

-- Mentos pro
;with cte as (
select origin,destination,
sum(case when oneway_round='O' then ticket_count else ticket_count*2 end) as tickets_sold 
from #tickets group by origin,destination)
select origin,destination,tickets_sold from cte 
where tickets_sold=(select max(tickets_sold) from cte)
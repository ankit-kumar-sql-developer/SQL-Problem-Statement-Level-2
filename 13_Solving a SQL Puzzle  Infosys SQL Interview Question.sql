
create table #input (
id int,
formula varchar(10),
value int
)
insert into #input values (1,'1+4',10),(2,'2+1',5),(3,'3-2',40),(4,'4-1',20);

;with cte as (
Select *,left(formula,1) as d1, right(formula,1) as d2,
substring(formula,2,1) as operation from #input )
select cte.id,cte.value,cte.formula,ip1.value as d1_value,
ip2.value as d2_value,cte.operation,
case when operation = '+' then ip1.value+ ip2.value else  ip1.value-ip2.value end as new_value
from cte 
inner join #input ip1 on cte.d1= ip1.id
inner join #input ip2 on cte.d2= ip2.id


-- 
/*
if we have two or three digit id's then we can't use  left/right  functions.
insert into input values (10,'10+11',10);
insert into input values (11,'10+11',34); */

with cte2 AS
(
  select *, (charindex('+', formula) +  charindex('-', formula)) as operator_index
 from #input
), cte3 as (
  select substrING(formula, 1, operator_index - 1) as id1,
  substrING(formula, operator_index, 1) as operator,
  substrING(formula, operator_index + 1, len(formula) - operator_index) as id2
  from cte2
  )
  select b.id, b.formula, b.value ,
  case when a.operator = '+' then b.value + c.value else b.value - c.value end as output
  from cte3 as A
 left join #input as b  
  on a.id1 = b.id
inner join #input as C
  on a.id2 = c.id;

--
  with input as (
select 10 as id,'10+130' as formula,10 as value
union 
select 11 as id,'11+10' as formula,5 as value
union 
select 12 as id,'12-11' as formula,40 as value
union 
select 130 as id,'130-10' as formula,20 as value
),
CTE AS
(
select * , LEFT(formula,PATINDEX('%[+,-]%',formula)-1) as l , 
SUBSTRING(formula ,PATINDEX('%[+,-]%',formula)+1 , len(formula) - PATINDEX('%[+,-]%',formula)) as r,
SUBSTRING(formula, PATINDEX('%[+,-]%',formula) ,1) as sign
from input
)

SELECT cte.*,l.value as l_val ,r.value as r_val ,
 case when sign ='+' then l.value + r.value 
       when sign='-' then l.value - r.value end as nw_val
FROM 
CTE 
JOIN input as l ON CTE.L = l.ID
JOIN INPUT as r ON CTE.R= r.ID
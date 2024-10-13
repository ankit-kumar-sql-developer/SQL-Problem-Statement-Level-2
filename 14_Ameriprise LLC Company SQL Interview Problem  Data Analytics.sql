
create table #Ameriprise_LLC
(
teamID varchar(2),
memberID varchar(10),
Criteria1 varchar(1),
Criteria2 varchar(1)
);
insert into #Ameriprise_LLC values 
('T1','T1_mbr1','Y','Y'),
('T1','T1_mbr2','Y','Y'),
('T1','T1_mbr3','Y','Y'),
('T1','T1_mbr4','Y','Y'),
('T1','T1_mbr5','Y','N'),
('T2','T2_mbr1','Y','Y'),
('T2','T2_mbr2','Y','N'),
('T2','T2_mbr3','N','Y'),
('T2','T2_mbr4','N','N'),
('T2','T2_mbr5','N','N'),
('T3','T3_mbr1','Y','Y'),
('T3','T3_mbr2','Y','Y'),
('T3','T3_mbr3','N','Y'),
('T3','T3_mbr4','N','Y'),
('T3','T3_mbr5','Y','N');

;with cte as (
select teamID,count(*) as cnt
from #Ameriprise_LLC
where Criteria1='Y' and Criteria2='Y'
group by teamID having count(*) >=2 )
Select al.teamid,al.memberid,al.criteria1,al.criteria2,
case when Criteria1='Y' and Criteria2='Y' and al.teamID is not null then 'Yes' else 'No' end as flag
from cte right join #Ameriprise_LLC al on cte.teamID = al.teamID

-- Solution 2

Select al.*,
case when Criteria1='Y' and Criteria2='Y' and 
Sum( case when Criteria1='Y' and Criteria2='Y' then 1 else 0 end ) 
over (partition by teamid)>=2 then 'Yes' else 'No' end as flag
from #Ameriprise_LLC al 

--
;with cte as (
select teamID,memberID,Criteria1,Criteria2, 
count(memberID) over(partition by teamID,Criteria1,Criteria2 ) rnk
from #Ameriprise_LLC )
select teamID,memberID,Criteria1,Criteria2,rnk,
case when  rnk>=2 and Criteria1='Y' and Criteria2='Y' then 'Y' else 'N' end as output
from cte group by teamID,memberID,Criteria1,Criteria2,rnk
order by teamID,memberid,rnk


-- 
Select *,case when ( 
sum ( case when criteria1 = criteria2 and criteria1 = 'y'  then 1 else 0 end) 
over(partition by teamid) )>1 and criteria1 = criteria2 and criteria1 = 'y' 
then 'q' else 'nq' end as verdict
from #ameriprise_llc

--
;with cte1 as(
select teamid,criteria1,criteria2,
case when criteria1='y' and criteria2='y' then 'yes' else 'no' end as flag
from #ameriprise_llc)
,cte2 as(
select teamid,flag,count(1) as cnt from cte1 group by teamid,flag having flag='yes')
select *,case when teamid in (select teamid from cte2 where cnt>=2) 
and criteria1='y' and criteria2='y' then 'yes qualified' else 'not qualified' end as output
from #ameriprise_llc ;

--
select *,case when criteria1 = 'y' and criteria2 = 'y' and qualify_count > 1 then 'y' else 'n' end as qualify_flag 
from (
select *,sum(case when criteria1 = 'y' and criteria2 = 'y' then 1 else 0 end) over (partition by teamid) as qualify_count
from #ameriprise_llc c
)temp

--
;with cte as (
select teamid ,sum(case when concat(criteria1, criteria2) = 'YY' then 1 else 0 end) as flag
from #ameriprise_llc group by teamid
having sum(case when concat(criteria1, criteria2) = 'YY' then 1 else 0 end) >= 2)
select *,(case when concat(criteria1, criteria2) = 'YY' and
teamid in(select teamid from cte) then 'Y' else 'N' end )as output
from #ameriprise_llc

--









--
insert into #Ameriprise_LLC values  ('T3','T3_mbr6','Y','Y');
with cte as (
Select teamID, Criteria1, Criteria2, memberId,
count(*) over(partition by teamID, Criteria1, Criteria2 order by count(*) rows between unbounded preceding and current row) as running_cnt
,count(*) over(partition by teamID, Criteria1, Criteria2 ) as couples
from Ameriprise_LLC
--where Criteria1  = 'Y' and Criteria2 = 'Y'
group by teamID, Criteria1, Criteria2, memberID
)
Select teamID, memberID, Criteria1, Criteria2,
	case When Criteria1 ='Y' and Criteria2 = 'Y'
	then
	case
		when couples%2 = 0 then 'Y'
		when couples > 1 and 
		running_cnt <= couples - 1 then 'Y'
		else 'N'
	end 
	else 'N'
	end as Qualified_for_Team
from CTE
order by teamID, memberID;
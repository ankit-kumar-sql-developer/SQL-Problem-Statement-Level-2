
create table #company_revenue 
(
company varchar(100),
year int,
revenue int
)

insert into #company_revenue values 
('abc1',2000,100),('abc1',2001,110),('abc1',2002,120),('abc2',2000,100),('abc2',2001,90),('abc2',2002,120)
,('abc3',2000,500),('abc3',2001,400),('abc3',2002,600),('abc3',2003,800);


-- solution 1
; with cte as (
select *, lag(revenue,1,0) over (partition  by company order by year) as prev_rev,
revenue - lag(revenue,1,0) over (partition  by company order by year) as sales_diff,
count(1) over (partition by company) as cnt
from #company_revenue )
,cte2 as (
select company,count(1) as cnt2,cnt
from cte where sales_diff > 0 
group by company,cnt ) --having cnt= count(1) 
select  * from cte2 where cnt2=cnt

-- Solution 2
; with cte as (
select *, lag(revenue,1,0) over (partition  by company order by year) as prev_rev,
revenue - lag(revenue,1,0) over (partition  by company order by year) as sales_diff,
count(1) over (partition by company) as cnt
from #company_revenue )
select *
from cte where company not in ( select company from cte where sales_diff < 0)


--
-- All Companies
 select [company] from #company_revenue
 except
-- companies where current year revenue is less than previous year's
select [company] from (
select [company], revenue as prioryearrevenue,
isnull((lead(revenue,1) over(partition by [company] order by [year])),revenue) as currentyearrevenue
from #company_revenue ) t 
where t.currentyearrevenue < prioryearrevenue

--
with cte as (
select *,case when revenue> lag(revenue,1,0) 
over(partition by company order by (select null)) then 1 else -1  end as flag
from #company_revenue
)
select distinct company  from #company_revenue where company not in
(select distinct company from cte where flag =-1)

--

;with cte as(
select *,lag(revenue,1,0) over(partition by company order by year) as newrev
from #company_revenue)
,cte2 as(
select  *,case when revenue  > newrev then 1 else 0 end as flag from cte 
)
select company, min(flag) from cte2
group by company having min(flag) >0

--
;with cte as
(select *, abs(row_number() over(partition by company order by year) - 
dense_rank() over(partition by company order by revenue)) as dr from #company_revenue )

select company from cte group by company having sum(dr)=0;

--

with cte as (
select *,
dense_rank() over(partition by company order by year) -
dense_rank() over(partition by company order by revenue) as year_rev_diff
from #company_revenue )
select company from cte 
group by company
having count(distinct year_rev_diff) = 1 and sum(year_rev_diff) = 0

--
; with cte  as (
select company,year,revenue,
case when (revenue - lag(revenue) over(partition by company order by year asc)) > 0 then 0
else 1 end as rev_flag  from #company_revenue )
select distinct company from cte group by company having sum(rev_flag)  <=1

--
with cte as (
select *, iif(lag(revenue) over(partition by company order by year) > revenue, 1, 0) flag
from #company_revenue )
select company from cte
group by company having count(distinct flag) = 1
-- having max(flag) = 0 but having min (flag) = 0 wont work here 

--
;with cte as (
select *,revenue - max(revenue) over(partition by company order by year asc) as rn
from #company_revenue )
select company,max(rn),min(rn) from cte
group by company having min(rn) = 0
-- having max(rn) = 0
/*
select company,rn,max(rn),min(rn) from cte
group by company,rn order by company */

--

with cte as (
select company , year , revenue
,lag(revenue , 1 , revenue)over(partition by company order by year) as next_year,
sign(revenue - lag(revenue , 1 , revenue)over(partition by company order by year)) as sighn
from #company_revenue)
,cte2 as (select company from cte where sighn = -1)
select distinct company from #company_revenue 
where company not in (select company from cte2)

--
;with year_by_revenue as 
(select company, year, revenue,
revenue - lag(revenue, 1, 0) over( partition by company order by year) as revenue_diff
from #company_revenue)
select company,sum(case when revenue_diff < 0 then 1 else 0 end)
from year_by_revenue
group by company
having sum(case when revenue_diff < 0 then 1 else 0 end) = 0

--
;with cte as
(select *,row_number()over(partition by company order by year) as rn_year,
row_number()over(partition by company order by revenue) as rn_revenue
from #company_revenue)
select company from cte group by company
having sum(case when rn_year=rn_revenue then 1 else 0 end)=3

--
--#calculate revenue difference wrt last year for each company and form a cte

;With cte as 
(Select Company,Year,
Revenue-Lag(revenue,1,0)over(partition by company order by year asc) as rev_diff
From #Company_revenue),
--#Calculate minimum revenue difference for each company for all years of operation and form another cte

cte2 as (
Select Company,Year,Min(rev_diff)over(partition by company) as min_diff
From cte )

--# Filter company with minimum revenue difference >0 using distinct
Select  distinct company From cte2 Where min_diff>0

--
;with cte as (
select *,
case when (revenue - lag(revenue) over w) > 0 or (lag(revenue) over w IS NULL) then 'Y'
else 'N' end check_com
from #company_revenue
window w as (partition by company order by year) )

select company from cte
group by company
having count(case when check_com != 'Y' then 1 end) = 0;

--
;with sample as (
select distinct c1.company 
from #company_revenue c1
inner join #company_revenue c2 on c1.company=c2.company
and c1.year=c2.year+1 where c1.revenue<c2.revenue)
select distinct c1.company 
from #company_revenue c1
where c1.company not in (select  company from sample )

--

;with cte as
(select*,
lead(revenue) over(partition by year order by revenue) as inc,
lag(revenue) over(partition by year order by revenue) as dec
from #company_revenue )
select company from cte
where inc > dec group by company

--

;with cte as (
select * 
, revenue - lag(revenue)over(partition by company order by year) as diff
from #company_revenue )
, cte1 as (
select *
, count(case when diff < 0 then 1 else null end ) over(partition by company ) as cnt
from cte )

select distinct company
from cte1
where cnt = 0
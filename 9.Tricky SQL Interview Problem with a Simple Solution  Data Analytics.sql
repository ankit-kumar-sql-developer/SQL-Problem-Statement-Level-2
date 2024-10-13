
Drop table if exists #purchases
create table #purchases(
	user_id int,
	product_id int,
	quantity int,
	purchase_date datetime
);

insert into #purchases values(536, 3223, 6,  '01/11/2022 12:33:44');
insert into #purchases values(827, 3585, 35, '02/20/2022 14:05:26');
insert into #purchases values(536, 3223, 5,  '03/02/2022 09:33:28');
insert into #purchases values(536, 1435, 10, '03/02/2022 08:40:00');
insert into #purchases values(827, 2452, 45, '04/09/2022 00:00:00');
insert into #purchases values(333, 1122, 8,  '06/02/2022 14:56:03');
insert into #purchases values(333, 1122, 10, '06/02/2022 02:00:00');
insert into #purchases values(333, 1122, 9,  '06/02/2022 01:00:00');
insert into #purchases values(836, 135, 10, '01/11/2022 01:00:00');
insert into #purchases values(836, 323, 6,  '01/11/2022 01:00:00');
insert into #purchases values(836, 323, 5,  '03/02/2022 09:33:28');

Select * from #purchases

-- Solution 1

select count(1) as users_num from (
Select user_id ,product_id , 
Count(distinct Cast(purchase_date as date)) as cnt
from #purchases
group by user_id ,product_id
having Count(distinct Cast(purchase_date as date)) >1 ) as t


-- Sol 2 Self Join 

Select count(distinct t1.user_id)
from #purchases as t1 inner join #purchases as t2
on  t1.user_id = t2.user_id and t1.product_id = t2.product_id and
datepart(day,t1.purchase_date) <>  datepart(day,t2.purchase_date)

-- Sol 3 
Select count(distinct user_id) 
from #purchases p where exists(
select 1 from #purchases p2 where p.user_id = p2.user_id AND p.product_id = p2.product_id 
AND convert(date,p.purchase_date) <> convert(date,p2.purchase_date))

-- Sol 4

select user_id from(
select user_id,product_id,Cast(purchase_date as date) as purchase_date ,
dense_rank() OVER(partition by user_id,product_id order by Cast(purchase_date as date)) as rn
from #purchases) as a
where rn=2;

-- Sol 5
with purchase_with_date as
(select *, Cast(purchase_date as date) as p_date from #purchases),
cte2 as (
select *,LEAD(p_date) over (partition by user_id, product_id order by p_date) as next_p_date
from purchase_with_date
)
select user_id from cte2
where next_p_date is not null and next_p_date <> p_date

--
;with cte as (
	select *
		,lead(purchase_date) over(Partition by user_id,product_id
		order by purchase_date) as Lead_Pur_Date
	from #Purchases
	)
select *,datediff(day,purchase_date,Lead_Pur_Date) --COUNT(Distinct user_id ) as Usr_Num
from CTE
where datediff(day,purchase_date,Lead_Pur_Date) <>0

--

select count(a.user_id) as total
from #purchases a, #purchases b
where datediff(day,a.purchase_date,b.purchase_date) > 0 
and (a.product_id = b.product_id) and (a.user_id = b.user_id);

---
select distinct user_id from  (
select user_id, product_id, quantity, purchase_date,
datediff(day,lag(purchase_date) over (partition by user_id, product_id order by purchase_date),purchase_date) as date_difference,
count(user_id) over (partition by user_id, product_id order by purchase_date rows between unbounded preceding and unbounded following) cnt 
from #Purchases) a 
where cnt>=2 and date_difference > 0

---
select user_id from (
select *, convert(date, purchase_date) as p_date,
rank() over(partition by product_id order by convert(date, purchase_date) asc) as rn from #Purchases) a
where rn > 1

--

select count(*) as users_num
from #purchases p1 join #purchases p2
on p1.user_id=p2.user_id  and p1.product_id=p2.product_id 
and convert(date, p1.purchase_date)< convert(date, p2.purchase_date)

-- VVI

select count(user_id) as users_num from  (
select user_id,product_id,count(user_id + product_id) as cnt from  ( 
select user_id, product_id,convert(date,purchase_date) pdate 
from #purchases group  by user_id,product_id,convert(date, purchase_date) 
)a group  by user_id, product_id ) b
where  cnt > 1;




---------------------------------------------------------------------------------------------------
/*Suppose if a user bought 2 different products on 2 different days then this query will return 
2 times count for that user. In below test data example 827 user_id will be considered 2 times using
this query*/

drop table if exists ##purchases
create table ##Purchases
(
user_id int ,
product_id int,
quantity int,
purchase_date datetime -- DD/MM/YYYY
);
insert into ##purchases values(333,1122,8,'06/02/2022 14:56:03');
insert into ##purchases values(333,1122,10,'06/02/2022 2:00:00');
insert into ##purchases values(333,1122,9,'06/02/2022 1:00:00');
insert into ##purchases values(536,1435,10,'03/02/2022 14:56:03');
insert into ##purchases values(536,3223,6,'01/11/2022 14:56:03');
insert into ##purchases values(536,3223,5,'03/02/2022 14:56:03');
insert into ##purchases values(827,1234,5,'06/02/2022 14:56:03');
insert into ##purchases values(827,1234,5,'09/02/2022 14:56:03');
insert into ##purchases values(827,7890,5,'11/02/2022 14:56:03');
insert into ##purchases values(827,7890,5,'12/02/2022 14:56:03');


Select  Count(Distinct user_id) as users_num from (
Select user_id,product_id,Count(distinct Convert(varchar(10),purchase_date,120)) as P_date_Count
from ##Purchases Group by user_id,product_id
having Count(distinct Convert(varchar(10),purchase_date,120)) > 1) A

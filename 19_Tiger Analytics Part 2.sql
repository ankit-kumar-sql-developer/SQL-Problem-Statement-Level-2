-- problem 2 

create table #sales 
(
    order_date date,
    customer varchar(512),
    qty int
);

insert into #sales (order_date, customer, qty) values ('2021-01-01', 'c1', '20');
insert into #sales (order_date, customer, qty) values ('2021-01-01', 'c2', '30');
insert into #sales (order_date, customer, qty) values ('2021-02-01', 'c1', '10');
insert into #sales (order_date, customer, qty) values ('2021-02-01', 'c3', '15');
insert into #sales (order_date, customer, qty) values ('2021-03-01', 'c5', '19');
insert into #sales (order_date, customer, qty) values ('2021-03-01', 'c4', '10');
insert into #sales (order_date, customer, qty) values ('2021-04-01', 'c3', '13');
insert into #sales (order_date, customer, qty) values ('2021-04-01', 'c5', '15');
insert into #sales (order_date, customer, qty) values ('2021-04-01', 'c6', '10');


Select * from #sales

select order_date, count(distinct customer) as cnt from (
Select *,
row_number() over (partition by customer order by order_date) as rn
from #sales ) a  
where rn=1 group by order_date

--

select a.first_visit_date,count(distinct customer) as new_customer
from (
select customer,min(order_date) as first_visit_date
from  #sales group  by customer ) a
group  by a.first_visit_date

--

; with cte as (
select order_date, customer from #sales group by customer)
select order_date, count(customer) as new_customer from cte 
group by month(order_date);

--
;with cte as (
select * ,min(order_date)over(partition by customer) as first_purchase
from #sales)
select order_date,SUM(flag) as new_customers from (
select *, case when order_date=first_purchase then 1 else 0 end as flag
from cte )a
group by order_date


--
;with cte as (select order_date,customer from #sales ) 
select  count( distinct a.customer) 
from cte as a left join cte as b on a.order_date>b.order_date and a.customer=b.customer
--order by a.customer
where b.order_date is null group by a.order_date ;

--

;with cte as (
select * ,min(order_date)over(partition by customer order by order_date) as first_order_date
from #sales)
select datename(month,order_date),
sum(case when order_date=first_order_date then 1 else 0 end ) as new_customer_count,
string_agg(customer,',') as cust
from cte  group by  datename(month,order_date)

--
select order_date, count(*) as new_customer_count 
from #sales s  where s.customer  not in 
(select  s1.customer  from #sales s1
where s.order_date>s1.order_date ) 
group by order_date
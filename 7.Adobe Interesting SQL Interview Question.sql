

Drop Table if exists #Customers
Create Table #Customers
           (Customer_id Int,
           Product Varchar (20),
           Revenue Int);

Insert Into #Customers Values
           (123,'Photoshop',50),
           (123,'Premier Pro',100),
           (123,'After Effects',50),
           (234,'Illustration',200),
           (234,'Premier Pro',100),
		   (912,'Photoshop',50),
		   (912,'Premier Pro',100),
		   (912,'Illustration',200)

Select * from #Customers

-- Solution 1

Select Customer_id, Sum(Revenue) as Revenue
from #Customers where Customer_id in (
select distinct Customer_id from #Customers
where Product = 'Photoshop' ) 
and Product !='Photoshop' group by Customer_id
Order by Customer_id

-- Solution 2

Select Customer_id, Sum(Revenue) as Revenue
from #Customers a where exists (
select 1 from  #Customers b where Product = 'Photoshop' 
and a.Customer_id= b.Customer_id) 
and Product !='Photoshop' group by Customer_id
Order by Customer_id

--
with cte AS
(
SELECT customer_id
FROM #Customers
where product ='Photoshop'
)
select customer_id,sum(revenue)
from #Customers
where product !='Photoshop'
and customer_id in ( select customer_id from cte )
group by customer_id

---

SELECT t1.customer_id, 
sum(case when product = 'Photoshop' then 0 else revenue end) revenue
FROM #Customers t1
join (Select customer_id from #Customers where product = 'Photoshop') t2
on t1.Customer_id = t2.Customer_id
group by t1.customer_id

--

;with cte as
(select customer_id, sum(revenue) as total_revenue from #Customers
group by customer_id )
,cte1 as(
select customer_id, sum(revenue) as photoshop_revenue from #Customers
where product = 'Photoshop' group by customer_id )

SELECT c.customer_id, c.total_revenue - c1.photoshop_revenue AS remaining_revenue
FROM cte c JOIN cte1 c1 ON c.customer_id = c1.customer_id;


--

select a.customer_id, 
count(distinct a.product) - max(pc.cnt) as Total_Distinct_Products_Except_Photoshop,
sum(a.revenue)-max(pc.photoshop_revenue)  as Revenue_From_Products_Except_Photoshop
from #Customers a inner join
( Select Customer_id, count(1) as cnt, sum(revenue) as photoshop_revenue from #Customers
where product = 'Photoshop' group by customer_id ) pc
on a.customer_id = pc.customer_id
group by a.customer_id;

--

;WITH one as (
SELECT customer_id,sum(revenue) as revenue FROM #Customers
where product <> 'Photoshop'
group by customer_id
),
two as
(select customer_id,product 
from #Customers
group by customer_id,product
having product= 'Photoshop'
)
select one.customer_id, one.revenue from one join two on one.customer_id=two.customer_id
order by customer_id

--

select customer_id,(sum-exception) as revenue from 
(select customer_id,sum(revenue) as sum,
sum(case when product in('Photoshop') then revenue else 0 end )
as exception
from #Customers 
group by customer_id) as dd
where exception !=0
order by customer_id


---

select customer_id,
sum(revenue)-sum(case when product='Photoshop' then revenue else 0 end)  as revenue
from #Customers
where customer_id in( select distinct customer_id from #Customers where product='Photoshop')
group by customer_id


-- sELF jOIN

select at.customer_id,
sum(at.Revenue) as 'Revenue'
from #Customers at
left join #Customers at1  on at.customer_id = at1.customer_id 
where at1.Product = 'Photoshop' and at.Product <> 'Photoshop'
and at1.customer_id is not null group by at.customer_id

--

select customer_id, sum(revenue) 
from #Customers where customer_id in 
(select customer_id from #Customers where product = 'Photoshop') 
and product <> 'Photoshop' group by customer_id;


--

with cte as 
(select customer_id,sum(revenue)  as c1val from #Customers group by 
customer_id), 
cte2 as (select customer_id,revenue as c2val from #Customers where product='Photoshop')

select c.customer_id , c1val-c2val from cte c, cte2 d where c.customer_id=d.customer_id order by 1 asc

--


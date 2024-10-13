create table #people
(id int primary key not null,
 name varchar(20),
 gender char(2));

create table #relations
(
    c_id int,
    p_id int,
    FOREIGN KEY (c_id) REFERENCES people(id),
    foreign key (p_id) references people(id)
);

insert into #people (id, name, gender)
values
    (107,'Days','F'),
    (145,'Hawbaker','M'),
    (155,'Hansel','F'),
    (202,'Blackston','M'),
    (227,'Criss','F'),
    (278,'Keffer','M'),
    (305,'Canty','M'),
    (329,'Mozingo','M'),
    (425,'Nolf','M'),
    (534,'Waugh','M'),
    (586,'Tong','M'),
    (618,'Dimartino','M'),
    (747,'Beane','M'),
    (878,'Chatmon','F'),
    (904,'Hansard','F');

insert into #relations(c_id, p_id)
values
    (145, 202),
    (145, 107),
    (278,305),
    (278,155),
    (329, 425),
    (329,227),
    (534,586),
    (534,878),
    (618,747),
    (618,904);

/*We have two tables people and relations. The people table contains the details of each individual
and the relations table contains the parent-child relationship between two individuals */

Select * from #people
Select * from #relations

-- Solution 1
;with cte as (
Select r.c_id , p.name as mother_name
from #relations r
inner join #people p on r.p_id =p.id and gender='F')
,cte2 as (
Select r.c_id , p.name as father_name
from #relations r
inner join #people p on r.p_id =p.id and gender='M' )

Select p.name as child_name, a.mother_name, b.father_name
from cte a inner join cte2 b on a.c_id = b.c_id
inner join #people p  on p.id = b.c_id

-- Solution 2
Select p.name,
max(m.name) as mother_name, max(f.name) as father_name
from #relations r 
left join  #people m  on r.p_id = m.id and m.gender= 'F'
left join  #people f  on r.p_id = f.id and f.gender= 'M'
inner join #people p  on p.id = r.c_id
group by p.name


-- Solution 3
Select p1.name,
Max(case when p.gender ='F' then p.name end) as mother_name,
Max(case when p.gender ='M' then p.name end) as father_name
from #relations r 
inner join #people p   on p.id  = r.p_id
inner join #people p1  on p1.id = r.c_id
group by p1.name

--

;with star as 
(select *,lead(name) over(partition by c_id order by gender) as mother,
lead(name) over(partition by c_id order by gender desc) as father 
from #relations as r 
left join #people as p on r.p_id=p.id )
select c_id,max(mother),max(father) from star group by c_id

--
;WITH fatherTable AS 
(
SELECT c_id, p_id, gender, name AS fatherName 
FROM #people
          INNER JOIN #relations on p_id = id
WHERE gender = 'M'
)
,
motherTable AS 
(
SELECT c_id, p_id, gender, name AS motherName 
FROM #people
          INNER JOIN #relations on p_id = id
WHERE gender = 'F'
)
, childTable AS
(
SELECT c_id, name AS childName 
FROM #people
          INNER JOIN #relations on c_id = id
)
SELECT childName,fatherName, motherName FROM 
fatherTable
          INNER JOIN motherTable on fatherTable.c_id = motherTable.c_id
		  INNER JOIN childTable on childTable.c_id = fatherTable.c_id 
GROUP BY childName,fatherName, motherName
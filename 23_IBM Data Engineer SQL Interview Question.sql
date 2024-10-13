

create table #families (
    id varchar(50),
    name varchar(50),
    family_size int
);

-- insert data into families table
insert into #families (id, name, family_size)
values 
    ('c00dac11bde74750b4d207b9c182a85f', 'alex thomas', 9),
    ('eb6f2d3426694667ae3e79d6274114a4', 'chris gray', 2),
    ('3f7b5b8e835d4e1c8b3e12e964a741f3', 'emily johnson', 4),
    ('9a345b079d9f4d3cafb2d4c11d20f8ce', 'michael brown', 6),
    ('e0a5f57516024de2a231d09de2cbe9d1', 'jessica wilson', 3);

-- create countries table
create table #countries (
    id varchar(50),
    name varchar(50),
    min_size int,
    max_size int
);

insert into #countries (id, name, min_size,max_size)
values 
    ('023fd23615bd4ff4b2ae0a13ed7efec9', 'bolivia', 2 , 4),
    ('be247f73de0f4b2d810367cb26941fb9', 'cook islands', 4,8),
    ('3e85ab80a6f84ef3b9068b21dbcc54b3', 'brazil', 4,7),
    ('e571e164152c4f7c8413e2734f67b146', 'australia', 5,9),
    ('f35a7bb7d44342f7a8a42a53115294a8', 'canada', 3,5),
    ('a1b5a4b5fc5f46f891d9040566a78f27', 'japan', 10,12);


	select * from #families
	select * from #countries

	select max(cnt) from (
	select f.name, count(*) as cnt
	--f.family_size, c.name,c.min_size,c.max_size
	from #families f 
	inner join #countries c on f.family_size between c.min_size and c.max_size
	group by f.name ) a

	-- Problem 2
	select count(*) from #countries where min_size <=
	(select max(family_size) from #families )


;with cte as (
select f.name family,c.name country,f.family_size,c.min_size 
from #families f
inner join #countries c on f.family_size >= c.min_size )
select family,count(*) eligible
from cte  group by family 
order by eligible desc
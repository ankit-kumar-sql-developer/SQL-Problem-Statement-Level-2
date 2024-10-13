/*There are 2 tables, first table has 5 records and second table has 10 records.
you can assume any Values in each of the tables. how many maximum and minimum records possible in case of
inner join, left join, right join	and full outer join */

Drop table if exists #T1
create table #T1( id_1 int);
Insert Into #T1 (id_1) Values (1)
Insert Into #T1 (id_1) Values (1)
Insert Into #T1 (id_1) Values (1)
Insert Into #T1 (id_1) Values (1)
Insert Into #T1 (id_1) Values (1)


Drop table if exists #T2
create table #T2( id_2 int);
Insert Into #T2(id_2)  Values (1)
Insert Into #T2 (id_2) Values (1)
Insert Into #T2 (id_2) Values (1)
Insert Into #T2 (id_2) Values (1)
Insert Into #T2 (id_2) Values (1)
Insert Into #T2(id_2)  Values (1)
Insert Into #T2 (id_2) Values (1)
Insert Into #T2 (id_2) Values (1)
Insert Into #T2 (id_2) Values (1)
Insert Into #T2 (id_2) Values (1)


Drop table if exists #T3
create table #T3( id_3 int);
Insert Into #T3(id_3)  Values (2)
Insert Into #T3 (id_3) Values (2)
Insert Into #T3 (id_3) Values (2)
Insert Into #T3 (id_3) Values (2)
Insert Into #T3 (id_3) Values (2)
Insert Into #T3(id_3)  Values (2)
Insert Into #T3 (id_3) Values (2)
Insert Into #T3 (id_3) Values (2)
Insert Into #T3 (id_3) Values (2)
Insert Into #T3 (id_3) Values (2)


select * from #T1
Select * from #T2

-- For Max case Put same value in both table 5*10 = 50

select *  from #T1 a Inner Join #T2 b on a.id_1 = b.id_2
select * from #T1 a left Join #T2 b on a.id_1 = b.id_2
select * from #T1 a full outer Join #T2 b on a.id_1 = b.id_2

-- For Min case Put diffrent value in both table = 0

select * from #T1 a Inner Join #T3 b on a.id_1 = b.id_3    -- 0
select * from #T1 a left Join #T3 b on a.id_1 = b.id_3     -- 5
select * from #T1 a right Join #T3 b on a.id_1 = b.id_3    -- 10
select * from #T1 a full outer Join #T3 b on a.id_1 = b.id_3  -- 15

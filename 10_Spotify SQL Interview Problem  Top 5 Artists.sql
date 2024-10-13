
drop table if exists #Artist
create table #Artist (
artist_id	integer,artist_name	varchar (100),label_owner	varchar(100) )

insert into #Artist Values
 (101,'Ed Sheeran','Warner Music Group')
,(120,'Drake','Warner Music Group')
,(125,'Bad Bunny','Rimas Entertainment')
,(145,'Lady Gaga','Interscope Records')
,(160,'Chris Brown','RCA Records')
,(200,'Adele','Columbia Records')
,(240,'Katy Perry','Capitol Records')
,(250,'The Weeknd','Universal Music Group')
,(260,'Taylor Swift','Universal Music Group')
,(270,'Ariana Grande','Universal Music Group')

drop table if exists #songs
create table #songs (
song_id	integer,artist_id integer,name	varchar(100) )

insert into #songs Values
 (55511,101,'Perfect')
,(45202,101,'Shape of You')
,(22222,120,'One Dance')
,(19960,120,'Hotline Bling')
,(12636,125,'Mia')
,(69820,125,'Dakiti')
,(44552,125,'Callaita')
,(11254,145,'Bad Romance')
,(33101,160,'Go Crazy')
,(23299,200,'Hello')
,(89633,240,'Last Friday Night')
,(28079,200,'Someone Like You')
,(13997,120,'Rich Flex')
,(14525,260,'Cruel Summer')
,(23689,260,'Blank Space')
,(54622,260,'Wildest Dreams')
,(62887,260,'Anti-Hero')
,(56112,270,'7 Rings')
,(86645,270,'Thank U, Next')
,(87752,260,'Karma')
,(23339,250,'Blinding Lights')

drop table if exists #global_song_rank 
create table #global_song_rank (day integer,song_id integer,rank integer)

insert into #global_song_rank Values
 (	1	,45202,	2)
,(	3	,45202,	2)
,(	15	,45202,	6)
,(	2	,55511,	2)
,(	1	,19960,	3)
,(	9	,19960,	15)
,(	23	,12636,	9)
,(	24	,12636,	7)
,(	2	,12636,	23)
,(	29	,12636,	7)
,(	1	,69820,	1)
,(	17	,44552,	8)
,(	11	,44552,	16)
,(	11	,11254,	5)
,(	12	,11254,	16)
,(	3	,33101,	16)
,(	6	,23299,	1)
,(	14	,89633,	2)
,(	9	,28079,	9)
,(	7	,28079,	10)
,(	40	,11254,	1)
,(	37	,23299,	5)
,(	19	,11254,	10)
,(	23	,89633,	10)
,(	52	,33101,	7)
,(	20	,55511,	10)
,(	7	,22222,	8)
,(	8	,44552,	1)
,(	1	,54622,	34)
,(	2	,44552,	1)
,(	2	,19960,	3)
,(	3	,260   ,1)
,(	3	,22222,	35)
,(	3	,56112,	3)
,(	4	,14525,	1)
,(	4	,23339,	29)
,(	4	,13997,	5)
,(	13	,87752,	1)
,(	14	,87752,	1)
,(	1	,11254,	12)
,(	51	,13997,	1)
,(	52	,28079,	75)
,(	15	,87752,	1)
,(	5	,14525,	1)
,(	6	,14525,	2)
,(	7	,14525,	1)
,(	40	,33101,	13)
,(	1	,54622,	84)
,(	7	,62887,	2)
,(	50	,89633,	67)
,(	50	,13997,	1)
,(	33	,13997,	3)
,(	1	,23299,	9)


-- 
Select at.artist_id,rn,at.artist_name from (
Select *, DENSE_RANK() over ( order by cnt desc) as rn from (
Select sg.artist_id,Count(1) as cnt from #global_song_rank  gsk
inner join #songs sg on gsk.song_id = sg.song_id
where rank <=10 group by sg.artist_id ) t ) q
inner join #Artist at on q.artist_id = at.artist_id
where rn <=5 order by rn,artist_name

--

;with cte1 as
(select #artist.artist_id,#artist.artist_name,#songs.song_id,
#global_song_rank.day,#global_song_rank.rank 
from #global_song_rank
left join #songs     on #global_song_rank.song_id=#songs.song_id
inner join #artist   on #songs.artist_id=#artist.artist_id
where #global_song_rank.rank<=10 )
, cte2 as
(select artist_name,count(song_id) as total_songs
from cte1 group by artist_name) 
, cte3 as (
select artist_name,
dense_rank() over(order by total_songs desc) as artist_rank
from  cte2 )
Select * from cte3 where artist_rank<=5


---
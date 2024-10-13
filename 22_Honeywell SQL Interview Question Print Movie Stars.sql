create table #movies (
    id int primary key,
    genre varchar(50),
    title varchar(100)
);

-- create reviews table
create table #reviews (
    movie_id int,
    rating decimal(3,1),
    foreign key (movie_id) references #movies(id)
);

-- insert sample data into movies table
insert into #movies (id, genre, title) values
(1, 'action', 'the dark knight'),
(2, 'action', 'avengers: infinity war'),
(3, 'action', 'gladiator'),
(4, 'action', 'die hard'),
(5, 'action', 'mad max: fury road'),
(6, 'drama', 'the shawshank redemption'),
(7, 'drama', 'forrest gump'),
(8, 'drama', 'the godfather'),
(9, 'drama', 'schindler''s list'),
(10, 'drama', 'fight club'),
(11, 'comedy', 'the hangover'),
(12, 'comedy', 'superbad'),
(13, 'comedy', 'dumb and dumber'),
(14, 'comedy', 'bridesmaids'),
(15, 'comedy', 'anchorman: the legend of ron burgundy');

-- insert sample data into reviews table
insert into #reviews (movie_id, rating) values
(1, 4.5),
(1, 4.0),
(1, 5.0),
(2, 4.2),
(2, 4.8),
(2, 3.9),
(3, 4.6),
(3, 3.8),
(3, 4.3),
(4, 4.1),
(4, 3.7),
(4, 4.4),
(5, 3.9),
(5, 4.5),
(5, 4.2),
(6, 4.8),
(6, 4.7),
(6, 4.9),
(7, 4.6),
(7, 4.9),
(7, 4.3),
(8, 4.9),
(8, 5.0),
(8, 4.8),
(9, 4.7),
(9, 4.9),
(9, 4.5),
(10, 4.6),
(10, 4.3),
(10, 4.7),
(11, 3.9),
(11, 4.0),
(11, 3.5),
(12, 3.7),
(12, 3.8),
(12, 4.2),
(13, 3.2),
(13, 3.5),
(13, 3.8),
(14, 3.8),
(14, 4.0),
(14, 4.2),
(15, 3.9),
(15, 4.0),
(15, 4.1);


select * from #movies
select * from #reviews

-- Solution 1

;with cte as (
select genre,title, avg(r.rating) as avg_rating,
row_number() over ( partition by genre order by  avg(r.rating) desc ) as rn
from #movies m
inner join #reviews r on m.id = r.movie_id
group by genre,title )
select genre,title,Round(avg_rating,0) as avg_rating,
replicate ('*',Round(avg_rating,0))  as stars
from cte where rn=1

--
;with cte as 
(
select m.genre, m.title, 
avg(r.rating) as avg_rating, replicate('*',round(avg(r.rating),0)) as stars,
rank() over(partition by m.genre order by avg(r.rating) desc) as rnk
from #movies m join #reviews r on m.id= r.movie_id
group by m.genre, m.title
)
select genre, string_agg(title,', ') as title, max(stars) as stars
from cte where rnk = 1
group by genre
order by genre

--

;with cte as 
(
select a.genre,a.title,round(b.avg_rating,0) as avg_rating,
case 
	when round(b.avg_rating,0) = 5 then '*****' 
    when round(b.avg_rating,0) = 4 then '****' 
    when round(b.avg_rating,0) = 3 then '***' 
    when round(b.avg_rating,0) = 2 then '**' 
    when round(b.avg_rating,0) = 1 then '*' 
    end as stars
    ,dense_rank() over(partition by a.genre order by b.avg_rating desc) as rnk
from #movies a 
left join (select movie_id, avg(rating) as avg_rating from #reviews group by movie_id ) b 
on a.id=b.movie_id
 )select genre,title,avg_rating,stars from cte where rnk = 1;
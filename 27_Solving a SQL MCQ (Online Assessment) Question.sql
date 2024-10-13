-- Create team table
CREATE TABLE #team (
    id CHAR(1) PRIMARY KEY,
    teamname VARCHAR(50),
    coach VARCHAR(50)
);

-- Create goal table
CREATE TABLE #goal (
    matchid INT,
    teamid CHAR(1),
    player VARCHAR(50),
    goal_time INT,
    PRIMARY KEY (matchid, teamid, player),
    FOREIGN KEY (teamid) REFERENCES #team(id)
);


CREATE TABLE #game (
    id INT PRIMARY KEY,
    mdate DATE,
    stadium VARCHAR(50),
    team1 CHAR(1),
    team2 CHAR(1),
    FOREIGN KEY (team1) REFERENCES #team(id),
    FOREIGN KEY (team2) REFERENCES #team(id)
);


-- Insert data into team table
INSERT INTO #team (id, teamname, coach)
VALUES 
('A', 'Team_A', 'Coach_A'),
('B', 'Team_B', 'Coach_B'),
('C', 'Team_C', 'Coach_C'),
('D', 'Team_D', 'Coach_D');

-- Insert data into goal table
INSERT INTO #goal (matchid, teamid, player, goal_time)
VALUES 
(101, 'A', 'A1', 17),
(101, 'A', 'A9', 58),
(101, 'B', 'B7', 89),
(102, 'D', 'D10', 63);

-- Insert data into game table
INSERT INTO #game (id, mdate, stadium, team1, team2)
VALUES 
(101, '2019-01-04', 'stadium 1', 'A', 'B'),
(102, '2019-01-04', 'stadium 3', 'D', 'E'), -- E is another team not in the team table
(103, '2019-01-10', 'stadium 1', 'A', 'C'),
(104, '2019-01-13', 'stadium 2', 'B', 'E'); -- E is another team not in the team table


select * from #game
select * from #goal
select * from #team

Select #game.id, #game.mdate,team1,
sum(case when #game.team1 = #goal.teamid then 1 else 0 end) as team1_flag,
team2,
sum(case when #game.team2 = #goal.teamid then 1 else 0 end) as team2_flag 
from #game left join #goal on #game.id= #goal.matchid
group by #game.id, #game.mdate,team1,team2
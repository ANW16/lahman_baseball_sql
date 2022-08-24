-- Q1.		
SELECT MIN(yearid), MAX(yearid), (MAX(yearid) - MIN(yearid)) AS total_years
FROM teams;
-- Answer: 1871-2016, 145 years in total .

-- Q2.
WITH smallest_player AS 
   (SELECT playerid, namegiven, height
    FROM people
    ORDER BY height ASC
    LIMIT 1)
SELECT t.name, s.namegiven, s.height, COUNT(a.playerid) as games_played
FROM appearances as a
FULL JOIN smallest_player as s
USING(playerid)
LEFT JOIN teams as t
USING(teamid)
WHERE a.playerid = s.playerid
GROUP BY t.name, s.namegiven, s.height
-- Answer: Edward Carl of the St. Louis Browns, 52 games .
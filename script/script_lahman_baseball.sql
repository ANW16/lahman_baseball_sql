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
SELECT t.name, sp.namegiven, sp.height, COUNT(a.playerid) as games_played
FROM appearances as a
FULL JOIN smallest_player as sp
USING(playerid)
LEFT JOIN teams as t
USING(teamid)
WHERE a.playerid = sp.playerid
GROUP BY t.name, sp.namegiven, sp.height;
-- Answer: Edward Carl of the St. Louis Browns, 52 games .

-- Q3.
WITH vandy_players AS 
   (SELECT DISTINCT(playerid)
    FROM collegeplaying
    WHERE schoolid ILIKE 'vandy'),
    vandy_majors AS 
   (SELECT p.playerid, CONCAT(p.namefirst, ' ', p.namelast) AS full_name
    FROM people as p
    INNER JOIN vandy_players as vp
    USING(playerid))				
SELECT vm.playerid, vm.full_name, COALESCE(SUM(s.salary),0) AS total_salary
FROM salaries as s
FULL JOIN vandy_majors as vm
USING(playerid)
WHERE vm.playerid IS NOT NULL
GROUP BY vm.full_name, vm.playerid
ORDER BY total_salary DESC
-- Answer: David Price has earned $81,851,296 from major league .
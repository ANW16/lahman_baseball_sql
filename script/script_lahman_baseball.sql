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
ORDER BY total_salary DESC;
-- Answer: David Price has earned $81,851,296 from major league .

-- Q4.
SELECT yearid, SUM(po) AS total_putouts, 
CASE
	WHEN pos ILIKE 'OF' THEN 'Outfield'
	WHEN pos ILIKE 'SS' OR pos ILIKE '%B' THEN 'Infield'
	WHEN pos ILIKE 'P' OR pos ILIKE 'C'  THEN 'Battery'
END AS field_pos
FROM fielding
WHERE yearid = '2016'
GROUP BY yearid, field_pos
ORDER BY total_putouts DESC;
-- Answer: Infield - 58,934/ Battery - 41,424/ Outfield - 29,560 .

-- Q5.
SELECT ROUND((SUM(so)/SUM(g)::decimal),2) AS avg_so, ROUND((SUM(hr)/SUM(g)::decimal),2) AS avg_hr,
CASE 
	WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
END AS decade
FROM teams
WHERE yearid BETWEEN 1920 AND 2009
GROUP BY decade
ORDER BY decade ASC;
-- Answer: Both home runs and strikeouts have increased with each decade .

-- Q6.
SELECT b.yearid, CONCAT(p.namefirst, ' ', p.namelast) AS name, b.sb, b.cs, 
       ROUND(b.sb/(b.sb+b.cs)::decimal, 2) AS success_rate
FROM batting AS b
INNER JOIN people AS p
USING(playerid)
WHERE b.sb + b.cs >= 20 AND b.yearid = '2016'
ORDER BY success_rate DESC;
-- Answer: Highest success rate belongs to Chris Owings, 91% .

-- Q7a. (W/ Problem Year)
SELECT yearid, teamid, wswin, w
FROM teams
WHERE yearid >= 1970 AND wswin ILIKE 'N'
ORDER BY w DESC;	
-- Answer: Seattle Mariners, 116 wins and lost the world series .
SELECT yearid, teamid, wswin, w
FROM teams
WHERE yearid >= 1970 AND wswin ILIKE 'Y'
ORDER BY w ASC;
-- Answer: Los Angeles Dodgers, 63 wins and won the world series .

/*
The 1981 season had a players' strike, which lasted from June 12 to July 31, and split the season into two halves. 
Teams that won their division in each half of the season advanced to the playoffs. 
This was the first split season in American League history and the cause of the low win count.
*/

-- Q7b. (Excluding Problem Year)
SELECT yearid, teamid, wswin, w
FROM teams
WHERE yearid >= 1970 AND yearid <> 1981 AND wswin ILIKE 'N'
ORDER BY w DESC;
-- Answer: Seattle Mariners, 116 wins and lost the world series .
SELECT yearid, teamid, wswin, w
FROM teams
WHERE yearid >= 1970 AND yearid <> 1981 AND wswin ILIKE 'Y'
ORDER BY w ASC;
-- Answer: St. Louis Cardinals, 83 wins and won the world series .

-- Q7c. 
WITH most_season_wins AS 
    (SELECT teams.yearid, MAX(w) AS most_w
     FROM teams
     WHERE teams.yearid >= 1970
     GROUP BY teams.yearid
     ORDER BY teams.yearid ASC)

SELECT CONCAT((ROUND((COUNT(DISTINCT(t.yearid))::decimal)/46, 2)*100), '%') as percent_wins
FROM most_season_wins as msw 
INNER JOIN teams as t
USING (yearid)
WHERE t.w = msw.most_w AND t.wswin = 'Y';
-- Answer: Since 1970 teams with the most wins that season had a 26% chance of winning the world series .
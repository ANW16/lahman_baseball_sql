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

-- Q8a. (Top 5)
SELECT p.park_name, tf.franchname, (h.attendance / h.games) AS atd_avg
FROM homegames as h
INNER JOIN parks as p 
USING(park)
INNER JOIN teams as t 
ON t.teamid = h.team 
INNER JOIN teamsfranchises as tf
USING(franchid)
WHERE h.year = 2016 AND h.games >= 10 AND tf.franchname <> 'Washington Senators'
GROUP BY tf.franchname, p.park_name, h.attendance, h.games
ORDER BY atd_avg DESC
LIMIT 5;
-- Answer: All have an average attendace of roughly 40,000 or higher .

-- Q8b. (Bottem 5)
SELECT p.park_name, tf.franchname, (h.attendance / h.games) AS atd_avg
FROM homegames as h
INNER JOIN parks as p 
USING(park)
INNER JOIN teams as t 
ON t.teamid = h.team 
INNER JOIN teamsfranchises as tf
USING(franchid)
WHERE h.year = 2016 AND h.games >= 10 AND tf.franchname <> 'Washington Senators'
GROUP BY tf.franchname, p.park_name, h.attendance, h.games
ORDER BY atd_avg ASC
LIMIT 5;
-- Answer: All have an average attendace of roughly 21,600 or lower .

-- Q9.
WITH tsn_managers AS
   (SELECT playerid, awardid, lgid
	FROM awardsmanagers
	WHERE lgid IN ('AL', 'NL')
    AND awardid ILIKE 'TSN Manager of the Year'
    GROUP BY playerid, awardid, lgid),
alnl_winners AS
   (SELECT playerid
    FROM tsn_managers
    WHERE lgid IN ('AL', 'NL')
    GROUP BY playerid
    HAVING count(playerid) >= 2)

SELECT (CONCAT(p.namefirst, ' ', p.namelast)) as name, am.yearid, am.lgid, m.teamid
FROM alnl_winners as anw
LEFT JOIN awardsmanagers as am
USING(playerid)
LEFT JOIN people as p
USING(playerid)
LEFT JOIN managers as m
ON (m.playerid = anw.playerid AND
m.lgid = am.lgid AND
m.yearid = am.yearid)
WHERE am.awardid ILIKE 'TSN Manager of the Year';
-- Answer: 2 managers, Jim Leyland and Davey Johnson .

-- Q10.
WITH highest_hr AS
   (SELECT playerid, yearid, MAX(hr) as most_hr
    FROM batting
    GROUP BY playerid, yearid),
decade_players AS
   (SELECT playerid
    FROM batting
    GROUP BY playerid
    HAVING count(playerid) >= 10)

SELECT (CONCAT(p.namefirst, ' ', p.namelast)) as name, hh.most_hr
FROM decade_players as dp
LEFT JOIN highest_hr as hh
USING(playerid)
LEFT JOIN people as p
USING(playerid)
WHERE yearid = 2016 AND most_hr <> 0
ORDER BY hh.most_hr DESC;
-- Answer: Nelson Cruz hit his career high of 43 home runs in 2016 .

-- Q11.
WITH team_salary AS
   (SELECT s.teamid, SUM(s.salary) as spending, 
    SUM(t.w) as wins, ROUND((SUM(s.salary)/SUM(t.w))::decimal,2) as cash_per_win, s.yearid
    FROM salaries as s
    LEFT JOIN teams as t
    ON (s.teamid = t.teamid AND s.yearid = t.yearid AND s.lgid = t.lgid)
    WHERE s.yearid >=2000
    GROUP BY s.teamid, s.yearid
    ORDER BY s.teamid, s.yearid ASC)
    
SELECT yearid, teamid, spending, 
spending-LAG(spending) OVER(PARTITION BY teamid ORDER BY yearid ASC) as spending_diff, 
wins,
wins-LAG(wins) OVER(PARTITION BY teamid ORDER BY yearid ASC) as win_diff, 
cash_per_win
FROM team_salary
-- Answer: More spending doesn't seem to result in more wins .

-- Q12a.
WITH hgstats AS 
    (SELECT year, team, t.park, SUM(hg.attendance) as total_attendace, SUM(w) as total_wins
    FROM homegames as hg
    LEFT JOIN teams as t
    ON (t.teamid = hg.team AND t.yearid = hg.year)
    WHERE year >=2000 AND team = teamid
    GROUP BY year, t.park, team
    ORDER BY team, year ASC)

SELECT year, team, park, total_attendace, 
total_attendace-LAG(total_attendace) OVER(PARTITION BY team ORDER BY year ASC) as attendace_diff,
total_wins,
total_wins-LAG(total_wins) OVER(PARTITION BY team ORDER BY year ASC) as win_diff
FROM hgstats
-- 
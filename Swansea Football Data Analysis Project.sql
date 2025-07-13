USE football;

SELECT * FROM clean_matches;


-- Creating filter on Swansea City FC Data



CREATE VIEW swansea_city_matches_v AS
SELECT
    division,
    match_date,
    home_team,
    away_team,
    home_elo_pre_match,
    away_elo_pre_match,
    ft_home_goals,
    ft_away_goals,
    ft_result,
    ht_home_goals,
    ht_away_goals,
    ht_result,
    home_shots,
    away_shots,
    home_shots_on_target,
    away_shots_on_target,
    home_fouls,
    away_fouls,
    home_corners,
    away_corners,
    home_yellow_cards,
    away_yellow_cards,
    home_red_cards,
    away_red_cards,
    odd_home,
    odd_draw,
    odd_away
FROM
    clean_matches
WHERE
    home_team = 'Swansea' OR away_team = 'Swansea'; 
    
    SELECT * FROM swansea_city_matches_v;
    
    -- Swansea City FC Analysis 
    
    
    -- 1. Overall Win/Loss/Draw Record for Swansea City FC (2023-2025)
    
    SELECT
    SUM(CASE
        WHEN (home_team = 'Swansea' AND ft_result = 'H') OR (away_team = 'Swansea' AND ft_result = 'A') THEN 1
        ELSE 0
    END) AS swansea_wins,
    SUM(CASE
        WHEN (home_team = 'Swansea' AND ft_result = 'A') OR (away_team = 'Swansea' AND ft_result = 'H') THEN 1
        ELSE 0
    END) AS swansea_losses,
    SUM(CASE
        WHEN ft_result = 'D' THEN 1
        ELSE 0
    END) AS swansea_draws,
    COUNT(*) AS total_matches
FROM
    swansea_city_matches_v
WHERE
    match_date >= '2023-08-01' AND match_date <= '2025-06-30';
    
-- 2. Win/Loss/Draw Record by Home vs. Away for Swansea City (2023-2025 Seasons)

SELECT
    'Swansea' AS team, -- Added 'team' column
    'Home' AS match_location,
    SUM(CASE WHEN ft_result = 'H' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN ft_result = 'D' THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN ft_result = 'A' THEN 1 ELSE 0 END) AS losses,
    COUNT(*) AS total_games
FROM
    swansea_city_matches_v
WHERE
    home_team = 'Swansea'
    AND match_date >= '2023-08-01' AND match_date <= '2025-06-30' -- Filter added
GROUP BY
    team, match_location

UNION ALL

SELECT
    'Swansea' AS team, -- Added 'team' column
    'Away' AS match_location,
    SUM(CASE WHEN ft_result = 'A' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN ft_result = 'D' THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN ft_result = 'H' THEN 1 ELSE 0 END) AS losses,
    COUNT(*) AS total_games
FROM
    swansea_city_matches_v
WHERE
    away_team = 'Swansea'
    AND match_date >= '2023-08-01' AND match_date <= '2025-06-30' -- Filter added
GROUP BY
    team, match_location;
    
-- 3. Goals Scored and Conceded Completed
SELECT
    'Overall' AS metric_type,
    SUM(CASE WHEN home_team = 'Swansea' THEN ft_home_goals ELSE ft_away_goals END) AS total_goals_scored,
    SUM(CASE WHEN home_team = 'Swansea' THEN ft_away_goals ELSE ft_home_goals END) AS total_goals_conceded,
    AVG(CASE WHEN home_team = 'Swansea' THEN ft_home_goals ELSE ft_away_goals END) AS avg_goals_scored_per_game,
    AVG(CASE WHEN home_team = 'Swansea' THEN ft_away_goals ELSE ft_home_goals END) AS avg_goals_conceded_per_game
FROM
    swansea_city_matches_v
WHERE
    match_date >= '2023-08-01' AND match_date <= '2025-06-30' -- Filter added

UNION ALL

SELECT
    'Home' AS metric_type,
    SUM(ft_home_goals) AS total_goals_scored,
    SUM(ft_away_goals) AS total_goals_conceded,
    AVG(ft_home_goals) AS avg_goals_scored_per_game,
    AVG(ft_away_goals) AS avg_goals_conceded_per_game
FROM
    swansea_city_matches_v
WHERE
    home_team = 'Swansea'
    AND match_date >= '2023-08-01' AND match_date <= '2025-06-30' -- Filter added

UNION ALL

SELECT
    'Away' AS metric_type,
    SUM(ft_away_goals) AS total_goals_scored,
    SUM(ft_home_goals) AS total_goals_conceded,
    AVG(ft_away_goals) AS avg_goals_scored_per_game,
    AVG(ft_home_goals) AS avg_goals_conceded_per_game
FROM
    swansea_city_matches_v
WHERE
    away_team = 'Swansea'
    AND match_date >= '2023-08-01' AND match_date <= '2025-06-30';
    
    -- 4. Clean Sheet Percentage for Swansea City (2023-2025 Seasons)
    
    SELECT
    SUM(CASE
        WHEN (home_team = 'Swansea' AND ft_away_goals = 0) OR (away_team = 'Swansea' AND ft_home_goals = 0) THEN 1
        ELSE 0
    END) AS total_clean_sheets,
    COUNT(*) AS total_matches,
    (SUM(CASE
        WHEN (home_team = 'Swansea' AND ft_away_goals = 0) OR (away_team = 'Swansea' AND ft_home_goals = 0) THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*)) AS clean_sheet_percentage
FROM
    swansea_city_matches_v
WHERE
    match_date >= '2023-08-01' AND match_date <= '2025-06-30'; 
    
    -- 5. Shots and Shots on Target Analysis for Swansea City (2023-2025 Seasons)
    
    SELECT
    'Overall' AS metric_type,
    AVG(CASE WHEN home_team = 'Swansea' THEN home_shots ELSE away_shots END) AS avg_shots,
    AVG(CASE WHEN home_team = 'Swansea' THEN home_shots_on_target ELSE away_shots_on_target END) AS avg_shots_on_target,
    (SUM(CASE WHEN home_team = 'Swansea' THEN ft_home_goals ELSE ft_away_goals END) * 100.0 /
     NULLIF(SUM(CASE WHEN home_team = 'Swansea' THEN home_shots_on_target ELSE away_shots_on_target END), 0)) AS goal_conversion_rate_on_target
FROM
    swansea_city_matches_v
WHERE
    (CASE WHEN home_team = 'Swansea' THEN home_shots_on_target ELSE away_shots_on_target END) IS NOT NULL
    AND (CASE WHEN home_team = 'Swansea' THEN home_shots_on_target ELSE away_shots_on_target END) > 0
    AND match_date >= '2023-08-01' AND match_date <= '2025-06-30' -- Filter added

UNION ALL

SELECT
    'Home' AS metric_type,
    AVG(home_shots) AS avg_shots,
    AVG(home_shots_on_target) AS avg_shots_on_target,
    (SUM(ft_home_goals) * 100.0 / NULLIF(SUM(home_shots_on_target), 0)) AS goal_conversion_rate_on_target
FROM
    swansea_city_matches_v
WHERE
    home_team = 'Swansea' AND home_shots_on_target IS NOT NULL AND home_shots_on_target > 0
    AND match_date >= '2023-08-01' AND match_date <= '2025-06-30' -- Filter added

UNION ALL

SELECT
    'Away' AS metric_type,
    AVG(away_shots) AS avg_shots,
    AVG(away_shots_on_target) AS avg_shots_on_target,
    (SUM(ft_away_goals) * 100.0 / NULLIF(SUM(away_shots_on_target), 0)) AS goal_conversion_rate_on_target
FROM
    swansea_city_matches_v
WHERE
    away_team = 'Swansea' AND away_shots_on_target IS NOT NULL AND away_shots_on_target > 0
    AND match_date >= '2023-08-01' AND match_date <= '2025-06-30';


-- Creating a league standings table to bring in league finishes 

CREATE TABLE league_standings (
    season VARCHAR(9) NOT NULL,        
    league_rank INT NULL,              
    team_name VARCHAR(100) NOT NULL,   
    matches_played INT NULL,           
    wins INT NULL,                     
    draws INT NULL,                    
    losses INT NULL,                 
    goals_for INT NULL,              
    goals_against INT NULL,         
    goal_difference INT NULL,         
    points INT NULL,                
    PRIMARY KEY (season, team_name)    
);

SELECT * FROM  league_standings;

-- Loading in Championship 2023-2024 standings

LOAD DATA LOCAL INFILE 'C:/Users/chorn/OneDrive/Documents/DA Routepath/SQL/Projects/Swansea Football Data Analysis Project June 25/Swansea Championship 2023-2024.csv' 
INTO TABLE league_standings
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS 
(
    league_rank,     
    matches_played,
    wins,
    draws,
    losses,
    goals_for,
    goals_against,
    goal_difference,
    points
)
SET
    season = '2023-2024';


LOAD DATA LOCAL INFILE 'C:/Users/chorn/OneDrive/Documents/DA Routepath/SQL/Projects/Swansea Football Data Analysis Project June 25/Swansea Championship 2024-2025.csv'
INTO TABLE league_standings
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS -- Skips the header row
(
    league_rank,     -- Maps to 'Rank' column in CSV
    team_name,
    matches_played,
    wins,
    draws,
    losses,
    goals_for,
    goals_against,
    goal_difference,
    points
)
SET
    season = '2024-2025';
    
-- 1.  Analysing Swansea Performance against league finish 

SELECT
    ls.season,
    ls.league_rank,
    SUM(CASE
        WHEN (sc.home_team = 'Swansea' AND sc.ft_result = 'H') OR (sc.away_team = 'Swansea' AND sc.ft_result = 'A') THEN 1
        ELSE 0
    END) AS swansea_wins,
    SUM(CASE
        WHEN (sc.home_team = 'Swansea' AND sc.ft_result = 'A') OR (sc.away_team = 'Swansea' AND sc.ft_result = 'H') THEN 1
        ELSE 0
    END) AS swansea_losses,
    SUM(CASE
        WHEN sc.ft_result = 'D' THEN 1
        ELSE 0
    END) AS swansea_draws,
    COUNT(sc.match_date) AS total_matches_in_season,

    -- Points Per Game (PPG)
    (SUM(CASE
        WHEN (sc.home_team = 'Swansea' AND sc.ft_result = 'H') OR (sc.away_team = 'Swansea' AND sc.ft_result = 'A') THEN 3
        WHEN sc.ft_result = 'D' THEN 1
        ELSE 0
    END) * 1.0 / COUNT(sc.match_date)) AS points_per_game,

    -- Win/Loss/Draw Percentages
    (SUM(CASE WHEN (sc.home_team = 'Swansea' AND sc.ft_result = 'H') OR (sc.away_team = 'Swansea' AND sc.ft_result = 'A') THEN 1 ELSE 0 END) * 100.0 / COUNT(sc.match_date)) AS win_percentage,
    (SUM(CASE WHEN (sc.home_team = 'Swansea' AND sc.ft_result = 'A') OR (sc.away_team = 'Swansea' AND sc.ft_result = 'H') THEN 1 ELSE 0 END) * 100.0 / COUNT(sc.match_date)) AS loss_percentage,
    (SUM(CASE WHEN sc.ft_result = 'D' THEN 1 ELSE 0 END) * 100.0 / COUNT(sc.match_date)) AS draw_percentage,

    -- Goal Metrics
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_home_goals ELSE sc.ft_away_goals END) AS avg_goals_scored,
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_away_goals ELSE sc.ft_home_goals END) AS avg_goals_conceded,
    (AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_home_goals ELSE sc.ft_away_goals END) -
     AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_away_goals ELSE sc.ft_home_goals END)) AS avg_goal_difference,

    -- Elo Metrics
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.home_elo_pre_match ELSE sc.away_elo_pre_match END) AS avg_swansea_elo,
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.away_elo_pre_match ELSE sc.home_elo_pre_match END) AS avg_opponent_elo,

    -- Offensive/Defensive Efficiency
    -- Goals per shot on target (Conversion Rate)
    (SUM(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_home_goals ELSE sc.ft_away_goals END) * 100.0 /
     NULLIF(SUM(CASE WHEN sc.home_team = 'Swansea' THEN sc.home_shots_on_target ELSE sc.away_shots_on_target END), 0)) AS goal_conversion_rate_on_target,
    -- Shots on target conceded per goal conceded (Opponent's Efficiency against Swansea)
    (SUM(CASE WHEN sc.home_team = 'Swansea' THEN sc.away_shots_on_target ELSE sc.home_shots_on_target END) * 1.0 /
     NULLIF(SUM(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_away_goals ELSE sc.ft_home_goals END), 0)) AS shots_on_target_conceded_per_goal_conceded,

    -- Discipline
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.home_yellow_cards ELSE sc.away_yellow_cards END) AS avg_yellow_cards,
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.home_red_cards ELSE sc.away_red_cards END) AS avg_red_cards

FROM
    swansea_city_matches_v sc
JOIN
    league_standings ls ON
        ls.team_name = 'Swansea' AND
        ls.season = (
            CASE
                WHEN MONTH(sc.match_date) >= 8 THEN CONCAT(YEAR(sc.match_date), '-', YEAR(sc.match_date) + 1)
                ELSE CONCAT(YEAR(sc.match_date) - 1, '-', YEAR(sc.match_date))
            END
        )
WHERE
    sc.match_date >= '2023-08-01' AND sc.match_date <= '2025-06-30'
GROUP BY
    ls.season, ls.league_rank
ORDER BY
    ls.season;
    
  -- Analysis 1 trends: improved league position (11th last season vs 14th 23-24), notable reduction in goals conceded 13.84% & better discipline leading to higher points against stronger opponents 

-- 2. Elo Difference by results 

SELECT
    ls.season,
    CASE
        WHEN (sc.home_team = 'Swansea' AND sc.ft_result = 'H') OR (sc.away_team = 'Swansea' AND sc.ft_result = 'A') THEN 'Win'
        WHEN sc.ft_result = 'D' THEN 'Draw'
        WHEN (sc.home_team = 'Swansea' AND sc.ft_result = 'A') OR (sc.away_team = 'Swansea' AND sc.ft_result = 'H') THEN 'Loss'
        ELSE 'Unknown'
    END AS match_outcome,
    AVG(
        CASE
            WHEN sc.home_team = 'Swansea' THEN (sc.home_elo_pre_match - sc.away_elo_pre_match)
            ELSE (sc.away_elo_pre_match - sc.home_elo_pre_match)
        END
    ) AS avg_elo_difference_vs_opponent
FROM
    swansea_city_matches_v sc
JOIN
    league_standings ls ON
        ls.team_name = 'Swansea' AND
        ls.season = (
            CASE
                WHEN MONTH(sc.match_date) >= 8 THEN CONCAT(YEAR(sc.match_date), '-', YEAR(sc.match_date) + 1)
                ELSE CONCAT(YEAR(sc.match_date) - 1, '-', YEAR(sc.match_date))
            END
        )
WHERE
    sc.match_date >= '2023-08-01' AND sc.match_date <= '2025-06-30'
    AND sc.home_elo_pre_match IS NOT NULL AND sc.away_elo_pre_match IS NOT NULL -- Ensure Elo data is present
GROUP BY
    ls.season, match_outcome
ORDER BY
    ls.season, match_outcome;
    
    -- Analysis 2 trends: 2024-2025 season saw losses predominantly against higher-ranked opponents rather than lower, more wins against such opposition also improved points gained by elo 
    
-- 3. Home vs Away Performance Breakdown by Season

SELECT
    ls.season,
    'Home' AS match_location,
    SUM(CASE WHEN sc.ft_result = 'H' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN sc.ft_result = 'D' THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN sc.ft_result = 'A' THEN 1 ELSE 0 END) AS losses,
    COUNT(*) AS total_games,
    AVG(sc.ft_home_goals) AS avg_goals_scored,
    AVG(sc.ft_away_goals) AS avg_goals_conceded,
    AVG(sc.home_shots) AS avg_shots,
    AVG(sc.home_shots_on_target) AS avg_shots_on_target
FROM
    swansea_city_matches_v sc
JOIN
    league_standings ls ON
        ls.team_name = 'Swansea' AND
        ls.season = (
            CASE
                WHEN MONTH(sc.match_date) >= 8 THEN CONCAT(YEAR(sc.match_date), '-', YEAR(sc.match_date) + 1)
                ELSE CONCAT(YEAR(sc.match_date) - 1, '-', YEAR(sc.match_date))
            END
        )
WHERE
    sc.home_team = 'Swansea'
    AND sc.match_date >= '2023-08-01' AND sc.match_date <= '2025-06-30'
GROUP BY
    ls.season, match_location

UNION ALL

SELECT
    ls.season,
    'Away' AS match_location,
    SUM(CASE WHEN sc.ft_result = 'A' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN sc.ft_result = 'D' THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN sc.ft_result = 'H' THEN 1 ELSE 0 END) AS losses,
    COUNT(*) AS total_games,
    AVG(sc.ft_away_goals) AS avg_goals_scored,
    AVG(sc.ft_home_goals) AS avg_goals_conceded,
    AVG(sc.away_shots) AS avg_shots,
    AVG(sc.away_shots_on_target) AS avg_shots_on_target
FROM
    swansea_city_matches_v sc
JOIN
    league_standings ls ON
        ls.team_name = 'Swansea' AND
        ls.season = (
            CASE
                WHEN MONTH(sc.match_date) >= 8 THEN CONCAT(YEAR(sc.match_date), '-', YEAR(sc.match_date) + 1)
                ELSE CONCAT(YEAR(sc.match_date) - 1, '-', YEAR(sc.match_date))
            END
        )
WHERE
    sc.away_team = 'Swansea'
    AND sc.match_date >= '2023-08-01' AND sc.match_date <= '2025-06-30'
GROUP BY
    ls.season, match_location
ORDER BY
    season, match_location;
    
    -- Analysis 3 trends: Stronger home record in 2024-2025 with more wins performing attack and defence. Decline in away form vs 23-24 season 
    
-- 4. Goal trends by half 

SELECT
    ls.season,
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ht_home_goals ELSE sc.ht_away_goals END) AS avg_ht_goals_scored,
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ht_away_goals ELSE sc.ht_home_goals END) AS avg_ht_goals_conceded,
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_home_goals ELSE sc.ft_away_goals END) AS avg_ft_goals_scored,
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_away_goals ELSE sc.ft_home_goals END) AS avg_ft_goals_conceded,
    (AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_home_goals ELSE sc.ft_away_goals END) - AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ht_home_goals ELSE sc.ht_away_goals END)) AS avg_second_half_goals_scored,
    (AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ft_away_goals ELSE sc.ft_home_goals END) - AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.ht_away_goals ELSE sc.ht_home_goals END)) AS avg_second_half_goals_conceded
FROM
    swansea_city_matches_v sc
JOIN
    league_standings ls ON
        ls.team_name = 'Swansea' AND
        ls.season = (
            CASE
                WHEN MONTH(sc.match_date) >= 8 THEN CONCAT(YEAR(sc.match_date), '-', YEAR(sc.match_date) + 1)
                ELSE CONCAT(YEAR(sc.match_date) - 1, '-', YEAR(sc.match_date))
            END
        )
WHERE
    sc.match_date >= '2023-08-01' AND sc.match_date <= '2025-06-30'
GROUP BY
    ls.season
ORDER BY
    ls.season;
    
    -- Analysis 4 trends: Improved first half defensive record in 24-25, but weaker second halves
    
    -- 5. Discipline Trends by Season 
    
    SELECT
    ls.season,
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.home_yellow_cards ELSE sc.away_yellow_cards END) AS avg_yellow_cards_per_game,
    AVG(CASE WHEN sc.home_team = 'Swansea' THEN sc.home_red_cards ELSE sc.away_red_cards END) AS avg_red_cards_per_game
FROM
    swansea_city_matches_v sc
JOIN
    league_standings ls ON
        ls.team_name = 'Swansea' AND
        ls.season = (
            CASE
                WHEN MONTH(sc.match_date) >= 8 THEN CONCAT(YEAR(sc.match_date), '-', YEAR(sc.match_date) + 1)
                ELSE CONCAT(YEAR(sc.match_date) - 1, '-', YEAR(sc.match_date))
            END
        )
WHERE
    sc.match_date >= '2023-08-01' AND sc.match_date <= '2025-06-30'
GROUP BY
    ls.season
ORDER BY
    ls.season;

-- Analysis 5 trends: 20% reduction in yellows 24-25 and massive 75% reduction in red cards improved consistency 



-- 6. Swansea Individual Match Data for detail to export to Tableau

SELECT
    sc.division,
    sc.match_date,
    sc.home_team,
    sc.away_team,
    sc.home_elo_pre_match,
    sc.away_elo_pre_match,
    sc.ft_home_goals,
    sc.ft_away_goals,
    sc.ft_result,
    sc.ht_home_goals,
    sc.ht_away_goals,
    sc.ht_result,
    sc.home_shots,
    sc.away_shots,
    sc.home_shots_on_target,
    sc.away_shots_on_target,
    sc.home_fouls,
    sc.away_fouls,
    sc.home_corners,
    sc.away_corners,
    sc.home_yellow_cards,
    sc.away_yellow_cards,
    sc.home_red_cards,
    sc.away_red_cards,
    sc.odd_home,
    sc.odd_draw,
    sc.odd_away,
    -- DERIVE THE SEASON COLUMN HERE
    (CASE WHEN MONTH(sc.match_date) >= 8 THEN CONCAT(YEAR(sc.match_date), '-', YEAR(sc.match_date) + 1) ELSE CONCAT(YEAR(sc.match_date) - 1, '-', YEAR(sc.match_date)) END) AS season
FROM
    swansea_city_matches_v sc
WHERE
    sc.match_date >= '2023-08-01' AND sc.match_date <= '2025-06-30'
ORDER BY sc.match_date;

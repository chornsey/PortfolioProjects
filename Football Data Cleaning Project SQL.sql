-- 1) Creating Football Database

CREATE DATABASE football;

USE football;

-- 2)  Creating staging table for MATCHES to bring in all relevant data from football datasets  

DROP TABLE staging_matches;

CREATE TABLE staging_matches (
	Division VARCHAR(10) NULL,
    MatchDate DATE NULL,
    MatchTime VARCHAR(10) NULL, 
    HomeTeam VARCHAR(100) NULL,
    AwayTeam VARCHAR(100) NULL,
    HomeElo DECIMAL(10,2) NULL,
    AwayElo DECIMAL(10,2) NULL,
    Form3Home DECIMAL(5,1) NULL,
    Form5Home DECIMAL(5,1) NULL,
    Form3Away DECIMAL(5,1) NULL,
    Form5Away DECIMAL(5,1) NULL,
    FTHome INT NULL,
    FTAway INT NULL,
    FTResult CHAR(1) NULL,
    HTHome INT NULL,
    HTAway INT NULL,
    HTResult CHAR(1) NULL,
    HomeShots INT NULL,
    AwayShots INT NULL,
    HomeTarget INT NULL,
    AwayTarget INT NULL,
    HomeFouls INT NULL,
    AwayFouls INT NULL,
    HomeCorners INT NULL,
    AwayCorners INT NULL,
    HomeYellow INT NULL,
    AwayYellow INT NULL,
    HomeRed INT NULL,
    AwayRed INT NULL,
    OddHome DECIMAL(10,2) NULL,
    OddDraw DECIMAL(10,2) NULL,
    OddAway DECIMAL(10,2) NULL,
    MaxHome DECIMAL(10,2) NULL,
    MaxDraw DECIMAL(10,2) NULL,
    MaxAway DECIMAL(10,2) NULL,
    Over25 DECIMAL(5,2) NULL,
    Under25 DECIMAL(5,2) NULL,
    MaxOver25 DECIMAL(5,2) NULL,
    MaxUnder25 DECIMAL(5,2) NULL,
    HandiSize DECIMAL(5,2) NULL,
    HandiHome DECIMAL(5,2) NULL,
    HandiAway DECIMAL(5,2) NULL,
    C_LTH DECIMAL(10,6) NULL,
    C_LTA DECIMAL(10,6) NULL,
    C_VHD DECIMAL(10,6) NULL,
    C_VAD DECIMAL(10,6) NULL,
    C_HTB DECIMAL(10,6) NULL,
    C_PHB DECIMAL(10,6) NULL
);

SELECT * FROM staging_matches;

-- Loading Matches CSV into staging table

LOAD DATA LOCAL INFILE 'C:/Users/chorn/Downloads/Matches.csv'
INTO TABLE staging_matches
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3) Creating staging table for ELO to bring in all relevant data from football datasets 

DROP TABLE staging_elo;

CREATE TABLE staging_elo (
    date DATE NULL,
    club VARCHAR(255) NULL,
    country VARCHAR(10) NULL,
    elo DECIMAL(10,2) NULL
);

SELECT * FROM staging_elo;

-- Loading Elo CSV into staging table

LOAD DATA LOCAL INFILE 'C:/Users/chorn/Downloads/EloRatings.csv'
INTO TABLE staging_elo
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT * FROM staging_elo;

-- 4) Full clean on Matches 

SELECT COUNT(*) AS original_row_count FROM staging_matches;

-- Trim Matches

UPDATE staging_matches
SET
    Division = TRIM(Division),
    MatchTime = TRIM(MatchTime),
    HomeTeam = TRIM(HomeTeam),
    AwayTeam = TRIM(AwayTeam),
    FTResult = TRIM(FTResult),
    HTResult = TRIM(HTResult);
    
-- Dupes 

SELECT
    Division, MatchDate, MatchTime, HomeTeam, AwayTeam, HomeElo, AwayElo,
    Form3Home, Form5Home, Form3Away, Form5Away, FTHome, FTAway, FTResult,
    HTHome, HTAway, HTResult, HomeShots, AwayShots, HomeTarget, AwayTarget,
    HomeFouls, AwayFouls, HomeCorners, AwayCorners, HomeYellow, AwayYellow,
    HomeRed, AwayRed, OddHome, OddDraw, OddAway, MaxHome, MaxDraw, MaxAway,
    Over25, Under25, MaxOver25, MaxUnder25, HandiSize, HandiHome, HandiAway,
    C_LTH, C_LTA, C_VHD, C_VAD, C_HTB, C_PHB,
    COUNT(*) AS duplicate_count
FROM
    staging_matches
GROUP BY
    Division, MatchDate, MatchTime, HomeTeam, AwayTeam, HomeElo, AwayElo,
    Form3Home, Form5Home, Form3Away, Form5Away, FTHome, FTAway, FTResult,
    HTHome, HTAway, HTResult, HomeShots, AwayShots, HomeTarget, AwayTarget,
    HomeFouls, AwayFouls, HomeCorners, AwayCorners, HomeYellow, AwayYellow,
    HomeRed, AwayRed, OddHome, OddDraw, OddAway, MaxHome, MaxDraw, MaxAway,
    Over25, Under25, MaxOver25, MaxUnder25, HandiSize, HandiHome, HandiAway,
    C_LTH, C_LTA, C_VHD, C_VAD, C_HTB, C_PHB
HAVING
    COUNT(*) > 1;   -- 0 rows returned so no dupes 
    
SELECT * FROM staging_matches;

-- Date cleaning 

SELECT COUNT(*) FROM staging_matches WHERE MatchDate IS NULL;  -- Count returned 0 no issues with date

-- Numeric validation

SELECT COUNT(*) AS null_elo_home FROM staging_matches WHERE HomeElo IS NULL;
SELECT COUNT(*) AS null_elo_away FROM staging_matches WHERE AwayElo IS NULL;
SELECT COUNT(*) AS null_ft_home FROM staging_matches WHERE FTHome IS NULL; -- Count returned 0 no issues with numeric data

-- Checking data consistency

SELECT DISTINCT HTResult
FROM staging_matches
WHERE HTResult NOT IN ('H', 'D', 'A') OR HTResult IS NULL; -- No issues in FTResult or HTResult 


-- Review

SELECT COUNT(*) AS final_row_count FROM staging_matches; -- Row count good


-- 5) Full clean on Elo 

SELECT COUNT(*) AS original_row_count FROM staging_elo; -- 245033 

-- Trim Elo

UPDATE staging_elo
SET
    club = TRIM(club),
    country = TRIM(country);

SELECT * FROM staging_elo;

-- Dupes 

SELECT
    date, club, country, elo,
    COUNT(*) AS duplicate_count
FROM
    staging_elo
GROUP BY
    date, club, country, elo
HAVING
    COUNT(*) > 1; -- No dupes 

-- Date cleaning

SELECT COUNT(*) FROM staging_elo WHERE date IS NULL; -- Count returned 0 

-- Numeric data validation

SELECT COUNT(*) AS null_elo_count FROM staging_elo WHERE elo IS NULL; -- Count returned 0

-- Data consistency 

SELECT DISTINCT club FROM staging_elo ORDER BY club;
SELECT DISTINCT country FROM staging_elo ORDER BY country;

-- Review 

SELECT COUNT(*) AS final_row_count FROM staging_elo; -- Row count 245033


-- Joining Matches and Elo together using a CTE to create a clean_matches table
-- Removing irrelevant data columns in CTE  e.g. MatchTime and detailed betting columns 

SELECT * FROM staging_matches;

-- Updating columns 

ALTER TABLE staging_matches RENAME COLUMN Division TO division;



DROP TABLE IF EXISTS clean_matches;

CREATE TABLE clean_matches AS
WITH joined_matches AS ( -- CTE is aliased as 'joined_matches'
    SELECT
        sm.division,
        sm.match_date,
        sm.home_team,
        sm.away_team,
        helo.elo AS home_elo_pre_match,
        aelo.elo AS away_elo_pre_match,
        sm.ft_home_goals,
        sm.ft_away_goals,
        sm.ft_result,
        sm.ht_home_goals,
        sm.ht_away_goals,
        sm.ht_result,
        sm.home_shots,
        sm.away_shots,
        sm.home_shots_on_target,
        sm.away_shots_on_target,
        sm.home_fouls,
        sm.away_fouls,
        sm.home_corners,
        sm.away_corners,
        sm.home_yellow_cards,
        sm.away_yellow_cards,
        sm.home_red_cards,
        sm.away_red_cards,
        sm.odd_home,
        sm.odd_draw,
        sm.odd_away
    FROM
        staging_matches sm
    LEFT JOIN
        staging_elo helo ON sm.home_team = helo.club AND sm.match_date = helo.date
    LEFT JOIN
        staging_elo aelo ON sm.away_team = aelo.club AND sm.match_date = aelo.date
)
SELECT
    jm.*
FROM
    joined_matches jm; 
    
    
-- Checking data in clean table

SELECT COUNT(*) AS total_matches_in_clean_table FROM clean_matches;
SELECT * FROM clean_matches LIMIT 10;

    
    
  
  
  




-- =========================================
-- GERMAN TRAIN DELAY ANALYSIS
-- Exploratory Data Analysis using SQLite
-- =========================================


-- =========================================
-- DATA EXPLORATION
-- =========================================

-- Total number of rows
SELECT COUNT(*) AS total_rows
FROM train_data;

-- Dataset time range
SELECT 
    MIN(arrival_plan) AS earliest_date,
    MAX(arrival_plan) AS latest_date
FROM train_data
WHERE arrival_plan <> '';

-- Missing arrival timestamps
SELECT COUNT(*) AS empty_arrival_plan
FROM train_data
WHERE arrival_plan = '';



-- =========================================
-- BASIC DELAY KPIs
-- =========================================

-- Average arrival delay
SELECT AVG(arrival_delay_m) AS avg_arrival_delay
FROM train_data;

-- Maximum arrival delay
SELECT MAX(arrival_delay_m) AS max_arrival_delay
FROM train_data;

-- Number of delayed stops
SELECT COUNT(*) AS delayed_stops
FROM train_data
WHERE arrival_delay_m >= 6;

-- Delay percentage
SELECT 
(
    (SELECT COUNT(*) 
     FROM train_data 
     WHERE arrival_delay_m >= 6) * 100.0
    /
    (SELECT COUNT(*) 
     FROM train_data)
) AS delay_percentage;

-- Punctuality rate
SELECT 
    100 - (
        (SELECT COUNT(*) 
         FROM train_data 
         WHERE arrival_delay_m >= 6) * 100.0
        /
        (SELECT COUNT(*) 
         FROM train_data)
    ) AS punctuality_rate;



-- =========================================
-- STATION ANALYSIS
-- =========================================

-- Stations with the highest delay rates
SELECT 
    station,
    COUNT(*) AS total_stops,
    SUM(CASE
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
GROUP BY station
HAVING total_stops > 1000
ORDER BY delay_rate DESC
LIMIT 10;



-- =========================================
-- TIME-BASED ANALYSIS
-- =========================================

-- Delayed stops by hour
SELECT 
    STRFTIME('%H', arrival_plan) AS hour,
    COUNT(*) AS delayed_stops
FROM train_data 
WHERE arrival_delay_m >= 6
AND arrival_plan <> ''
GROUP BY hour
ORDER BY hour;

-- Delay rate by hour
SELECT 
    STRFTIME('%H', arrival_plan) AS hour,
    COUNT(*) AS total_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
WHERE arrival_plan <> ''
GROUP BY hour
ORDER BY hour;

-- Delay rate by weekday
SELECT
    CASE 
        WHEN STRFTIME('%w', arrival_plan) = '0' THEN 'Sunday'
        WHEN STRFTIME('%w', arrival_plan) = '1' THEN 'Monday'
        WHEN STRFTIME('%w', arrival_plan) = '2' THEN 'Tuesday'
        WHEN STRFTIME('%w', arrival_plan) = '3' THEN 'Wednesday'
        WHEN STRFTIME('%w', arrival_plan) = '4' THEN 'Thursday'
        WHEN STRFTIME('%w', arrival_plan) = '5' THEN 'Friday'
        WHEN STRFTIME('%w', arrival_plan) = '6' THEN 'Saturday'
    END AS weekday,
    COUNT(*) AS total_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
WHERE arrival_plan <> ''
GROUP BY weekday
ORDER BY STRFTIME('%w', arrival_plan);



-- =========================================
-- DELAY CATEGORY ANALYSIS
-- =========================================

-- Distribution of delay categories
SELECT
    CASE
        WHEN arrival_delay_m < 6 THEN 'On Time'
        WHEN arrival_delay_m BETWEEN 6 AND 15 THEN 'Minor Delay'
        WHEN arrival_delay_m BETWEEN 16 AND 30 THEN 'Major Delay'
        ELSE 'Severe Delay'
    END AS delay_category,
    COUNT(*) AS total_stops
FROM train_data
WHERE arrival_plan <> ''
GROUP BY delay_category
ORDER BY total_stops DESC;



-- =========================================
-- STATION CATEGORY ANALYSIS
-- =========================================

-- Delay rate by station category
SELECT 
    category,
    COUNT(*) AS total_stops,
    SUM(CASE
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
GROUP BY category
HAVING total_stops > 1000
ORDER BY category;



-- =========================================
-- LINE ANALYSIS
-- =========================================

-- Train lines with the most delayed stops
SELECT
    line,
    COUNT(*) AS total_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
WHERE arrival_plan <> ''
GROUP BY line
HAVING total_stops > 1000
ORDER BY delayed_stops DESC
LIMIT 20;

-- Train lines with the highest delay rates
SELECT
    line,
    COUNT(*) AS total_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
WHERE arrival_plan <> ''
GROUP BY line
HAVING total_stops > 1000
ORDER BY delay_rate DESC
LIMIT 20;



-- =========================================
-- REGIONAL ANALYSIS
-- =========================================

-- Delay rate by state
SELECT 
    state,
    COUNT(*) AS total_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
WHERE arrival_plan <> ''
GROUP BY state
ORDER BY delay_rate DESC;

-- Delay rate by state and hour
SELECT
    state,
    STRFTIME('%H', arrival_plan) AS hour,
    COUNT(*) AS total_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
WHERE arrival_plan <> ''
GROUP BY state, hour
HAVING total_stops > 1000
ORDER BY delay_rate DESC
LIMIT 20;



-- =========================================
-- INVESTIGATIVE ANALYSIS:
-- RHEINLAND-PFALZ & LINE 26
-- =========================================

-- Most delay-prone lines in Rheinland-Pfalz
SELECT
    line,
    COUNT(*) AS total_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
WHERE arrival_plan <> ''
AND state = 'Rheinland-Pfalz'
GROUP BY line
HAVING total_stops > 1000
ORDER BY delay_rate DESC
LIMIT 20;

-- Delay rate of line 26 by hour
SELECT 
    STRFTIME('%H', arrival_plan) AS hour,
    COUNT(*) AS total_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
WHERE arrival_plan <> ''
AND line = '26'
GROUP BY hour
ORDER BY hour;

-- Delay hotspots on line 26
SELECT 
    station,
    COUNT(*) AS total_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) AS delayed_stops,
    SUM(CASE 
        WHEN arrival_delay_m >= 6 THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS delay_rate
FROM train_data
WHERE arrival_plan <> ''
AND line = '26'
GROUP BY station
HAVING total_stops > 100
ORDER BY delay_rate DESC;
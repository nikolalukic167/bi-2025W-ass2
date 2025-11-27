-- Assignment 2 ETL: dim_alertpeak
-- HINT: Seed fixed rows (keys 1000..1004) for None/Yellow/Orange/Red/Crimson.
-- EXAMPLE SHAPE:
-- TRUNCATE TABLE dwh2_xxx.dim_alertpeak;
-- INSERT INTO dwh2_xxx.dim_alertpeak (alertpeak_key, alert_level_name, alert_rank) VALUES
--   (1000, 'None', 0), (1001, 'Yellow', 1), (1002, 'Orange', 2), (1003, 'Red', 3), (1004, 'Crimson', 4);

-- Make A2 dwh2_xxx, stg2_xxx schemas the default for this session
SET search_path TO dwh2_xxx, stg2_xxx;

-- =======================================
-- Load dim_alertpeak
-- =======================================

-- Step 1: Truncate target table - dim_alertpeak
TRUNCATE TABLE dim_alertpeak RESTART IDENTITY CASCADE;

-- Step 2: Insert data into the dim_alertpeak
INSERT INTO dim_alertpeak (alertpeak_key, alert_level_name, alert_rank)
VALUES
 (1000, 'None',    0),
 (1001, 'Yellow',  1),
 (1002, 'Orange',  2),
 (1003, 'Red',     3),
 (1004, 'Crimson', 4);
 
 



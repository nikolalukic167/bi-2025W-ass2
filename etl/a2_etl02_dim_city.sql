-- Assignment 2 ETL: dim_city
-- HINT: Join stg_006.tb_city to stg_006.tb_country to populate:
--   country_name, city_name, population, latitude, longitude
-- Then, at the END, a separate UPDATE will set region_name via CASE

-- Make A2 dwh2_006, stg2_006 schemas the default for this session
SET search_path TO dwh2_006, stg2_006;

-- =======================================
-- Load dim_city
-- =======================================

-- Step 1: Truncate target table - dim_city
TRUNCATE TABLE dim_city RESTART IDENTITY CASCADE;

-- Step 2: Insert data into the dim_city
-- City (Region → Country → City)
INSERT INTO dim_city (country_name, city_name, population, latitude, longitude)
SELECT co.countryname, ci.cityname, ci.population, ci.latitude, ci.longitude
FROM tb_city ci
JOIN tb_country co ON co.id = ci.countryid
ORDER BY ci.cityname;

-- ==========================================================
-- Apply Geo patch - set region_name
-- ==========================================================

UPDATE dim_city
SET region_name = CASE country_name
  WHEN 'Austria'          THEN 'Central Europe'
  WHEN 'Croatia'          THEN 'Central Europe'
  WHEN 'Czech Republic'   THEN 'Central Europe'
  WHEN 'Germany'          THEN 'Central Europe'
  WHEN 'Hungary'          THEN 'Central Europe'
  WHEN 'Poland'           THEN 'Central Europe'

  WHEN 'Belgium'          THEN 'Western Europe'
  WHEN 'Denmark'          THEN 'Western Europe'
  WHEN 'Finland'          THEN 'Western Europe'
  WHEN 'France'           THEN 'Western Europe'
  WHEN 'Italy'            THEN 'Western Europe'
  WHEN 'Netherlands'      THEN 'Western Europe'
  WHEN 'United Kingdom'   THEN 'Western Europe'
  WHEN 'Spain'            THEN 'Western Europe'
  WHEN 'Sweden'           THEN 'Western Europe'
  
  WHEN 'Belarus'          THEN 'Eastern Europe'
  WHEN 'Greece'           THEN 'Eastern Europe'
  WHEN 'Russia'           THEN 'Eastern Europe'
  WHEN 'Serbia'           THEN 'Eastern Europe'
  WHEN 'Turkey'           THEN 'Eastern Europe'
  ELSE 'Other'
END;





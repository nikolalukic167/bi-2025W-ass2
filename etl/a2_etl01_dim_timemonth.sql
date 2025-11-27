-- Assignment 2 ETL: dim_timemonth
-- HINT: Generate months from 2023-01-01 to 2024-12-31, compute:
--   month_key (YYYYMM), year_num, quarter_num, month_num, month_name, mfirst_day, mlast_day, days_in_month
-- EXAMPLE SHAPE (replace with your complete solution):
-- TRUNCATE TABLE dwh2_xxx.dim_timemonth;
-- WITH months AS (...)
-- INSERT INTO dwh2_xxx.dim_timemonth (...)
-- SELECT ... FROM months;

-- Make A2 dwh2_xxx, stg2_xxx schemas the default for this session
SET search_path TO dwh2_xxx, stg2_xxx;

-- =======================================
-- Load dim_timemonth
-- =======================================

-- Step 1: Truncate target table, the dim_timemonth
TRUNCATE TABLE dim_timemonth RESTART IDENTITY CASCADE;

-- Step 2: Insert data into the dim_timeday
-- 1a) Time (months) for 2023-01 .. 2024-12
WITH months AS (
  SELECT date_trunc('month', dd)::date AS first_day
  FROM generate_series('2023-01-01'::date, '2024-12-31'::date, interval '1 month') AS g(dd)
)
INSERT INTO dim_timemonth (month_key, year_num, quarter_num, month_num, month_name, mfirst_day, mlast_day, days_in_month)
SELECT
  (EXTRACT(YEAR FROM first_day)::INT * 100 + EXTRACT(MONTH FROM first_day)::INT)       AS month_key,
  EXTRACT(YEAR FROM first_day)::INT                                                    AS year_num,
  EXTRACT(QUARTER FROM first_day)::INT                                                 AS quarter_num,
  EXTRACT(MONTH  FROM first_day)::INT                                                  AS month_num,
  TO_CHAR(first_day, 'Mon')                                                            AS month_name,
  first_day                                                                            AS mfirst_day,
  (first_day + INTERVAL '1 month - 1 day')::date                                       AS mlast_day,
  EXTRACT(DAY FROM (first_day + INTERVAL '1 month - 1 day'))::INT                      AS days_in_month
FROM months
ORDER BY first_day;




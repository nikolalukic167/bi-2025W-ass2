-- Assignment 2 ETL: ft_param_city_month
-- GRAIN: month_key × city_key × param_key

-- EXAMPLE SHAPE (sketch only):
-- TRUNCATE TABLE ft_param_city_month;
-- WITH cte1 AS (...),
--      cte2 AS (...),
--      cte3 AS (...),
--      ... AS (...),
--      final_cte AS (...)
-- INSERT INTO ft_param_city_month (...columns...)
-- SELECT ... FROM final_cte;

-- Make A2 dwh2_xxx, stg2_xxx schemas the default for this session
SET search_path TO dwh2_006, stg2_006;

-- =======================================
-- Load ft_param_city_month
-- =======================================

-- Step 1: Truncate target table - ft_param_city_month
TRUNCATE TABLE ft_param_city_month RESTART IDENTITY CASCADE;


-- Step 2: Transformation and Insertion
INSERT INTO ft_param_city_month (
	ft_pcm_key,
	month_key,
	city_key,
	param_key,
	alertpeak_key,
	reading_events_count,
    devices_reporting_count,
    recordedvalue_avg,
    recordedvalue_p95,
    exceed_days_any,
    data_volume_kb_sum,
    data_quality_avg,	
    missing_days
)
WITH 
-- 1. Helper: Map Alert Thresholds to Ranks (1=Yellow ... 4=Crimson)
cte_thresholds AS (
    SELECT 
        pa.paramid,
        pa.threshold,
        CASE a.alertname
            WHEN 'Yellow'  THEN 1
            WHEN 'Orange'  THEN 2
            WHEN 'Red'     THEN 3
            WHEN 'Crimson' THEN 4
            ELSE 0
        END AS alert_rank
    FROM stg2_006.tb_paramalert pa
    JOIN stg2_006.tb_alert a ON pa.alertid = a.id
),

-- 2. Augment Raw Readings with DWH Keys (City, Param)
cte_raw AS (
    SELECT
        -- Time Key (YYYYMM)
        (EXTRACT(YEAR FROM re.readat)::INT * 100 + EXTRACT(MONTH FROM re.readat)::INT) AS month_key,
        re.readat,
        re.sensordevid,
        re.recordedvalue,
        re.datavolumekb,
        re.dataquality,
        
        -- DWH Keys
        dc.city_key,
        dp.param_key,
        
        -- Keep Staging Param ID for threshold lookup
        re.paramid AS stg_param_id
    FROM stg2_006.tb_readingevent re
    JOIN stg2_006.tb_sensordevice sd ON re.sensordevid = sd.id
    JOIN stg2_006.tb_city sc       ON sd.cityid = sc.id
    JOIN stg2_006.tb_country sco   ON sc.countryid = sco.id
    -- Join to DWH Dim City
    JOIN dwh2_006.dim_city dc      ON dc.city_name = sc.cityname 
                                  AND dc.country_name = sco.countryname
    -- Join to DWH Dim Param
    JOIN stg2_006.tb_param sp      ON re.paramid = sp.id
    JOIN dwh2_006.dim_param dp     ON dp.param_name = sp.paramname
),

-- 3. Pre-aggregate to Day Grain to determine Daily Peak Values
--    (Necessary because alerts are based on the highest value in a day)
cte_daily_max AS (
    SELECT
        month_key,
        city_key,
        param_key,
        stg_param_id,
        readat,
        MAX(recordedvalue) AS max_daily_val
    FROM cte_raw
    GROUP BY month_key, city_key, param_key, stg_param_id, readat
),

-- 4. Calculate Daily Rank (0..4) based on Thresholds
cte_daily_rank AS (
    SELECT
        dm.month_key,
        dm.city_key,
        dm.param_key,
        dm.readat,
        -- Find the highest rank where daily max exceeded the threshold. 
        -- Coalesce to 0 (None) if no threshold exceeded.
        COALESCE(MAX(t.alert_rank), 0) AS daily_rank
    FROM cte_daily_max dm
    LEFT JOIN cte_thresholds t 
        ON dm.stg_param_id = t.paramid 
        AND dm.max_daily_val >= t.threshold
    GROUP BY dm.month_key, dm.city_key, dm.param_key, dm.readat
),

-- 5. Calculate Monthly Alert Metrics (Exceed Days + Monthly Peak Key)
cte_monthly_alerts AS (
    SELECT
        month_key,
        city_key,
        param_key,
        -- Count days where rank >= 1 (Yellow or higher)
        COUNT(CASE WHEN daily_rank >= 1 THEN 1 END) AS exceed_days_any,
        -- Get the maximum rank seen in the entire month (0..4), map to Key 1000..1004
        (1000 + MAX(daily_rank)) AS alertpeak_key,
        -- Count unique days with readings (for missing_days calc)
        COUNT(DISTINCT readat) AS days_with_readings
    FROM cte_daily_rank
    GROUP BY month_key, city_key, param_key
),

-- 6. Calculate Standard Monthly Measures (Avg, Sum, Count, P95)
cte_monthly_measures AS (
    SELECT
        month_key,
        city_key,
        param_key,
        -- Distinct (Device + Day)
        COUNT(DISTINCT (sensordevid, readat)) AS reading_events_count,
        -- Distinct Devices
        COUNT(DISTINCT sensordevid) AS devices_reporting_count,
        -- Averages and Sums
        AVG(recordedvalue) AS recordedvalue_avg,
        SUM(datavolumekb) AS data_volume_kb_sum,
        AVG(dataquality) AS data_quality_avg,
        -- P95 Percentile
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY recordedvalue) AS recordedvalue_p95
    FROM cte_raw
    GROUP BY month_key, city_key, param_key
)

-- 7. Final Join
SELECT
	ROW_NUMBER() OVER (ORDER BY m.month_key, m.city_key, m.param_key) AS ft_pcm_key,
    m.month_key,
    m.city_key,
    m.param_key,
    a.alertpeak_key,
    m.reading_events_count,
    m.devices_reporting_count,
    ROUND(m.recordedvalue_avg, 6) AS recordedvalue_avg,
    ROUND(m.recordedvalue_p95::numeric, 6) AS recordedvalue_p95,
    a.exceed_days_any,
    m.data_volume_kb_sum,
    ROUND(m.data_quality_avg, 6) AS data_quality_avg,
    -- Missing Days = Days in Month - Days with Readings
    (dt.days_in_month - a.days_with_readings) AS missing_days
FROM cte_monthly_measures m
JOIN cte_monthly_alerts a 
    ON m.month_key = a.month_key 
    AND m.city_key = a.city_key 
    AND m.param_key = a.param_key
JOIN dwh2_006.dim_timemonth dt 
    ON m.month_key = dt.month_key;
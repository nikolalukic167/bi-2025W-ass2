-- Make the A2's dwh2_xxx schema the default for this session
SET search_path TO dwh2_xxx;

-- Create schema
-- CREATE SCHEMA IF NOT EXISTS dwh2_xxx;

-- -------------------------------
-- 2) DROP TABLE before attempting to create Star Schema tables, drop in dependency order (fact first)
-- -------------------------------
DROP TABLE IF EXISTS dwh2_xxx.ft_param_city_month CASCADE;
DROP TABLE IF EXISTS dwh2_xxx.dim_alertpeak CASCADE;
DROP TABLE IF EXISTS dwh2_xxx.dim_param CASCADE;
DROP TABLE IF EXISTS dwh2_xxx.dim_city CASCADE;
DROP TABLE IF EXISTS dwh2_xxx.dim_timemonth CASCADE;


-- =========================
-- 3) CREATE TABLE statements for DIMENSIONS
-- =========================

-- 3.1) Time (Month) dimension
CREATE TABLE dim_timemonth (
    month_key       INT PRIMARY KEY            -- e.g., 202401
    , year_num        INT NOT NULL
    , quarter_num     INT NOT NULL CHECK (quarter_num BETWEEN 1 AND 4)
    , month_num       INT NOT NULL CHECK (month_num BETWEEN 1 AND 12)
    , month_name      VARCHAR(20) NOT NULL
    , mfirst_day      DATE NOT NULL
    , mlast_day       DATE NOT NULL
    , days_in_month   INT  NOT NULL CHECK (days_in_month BETWEEN 28 AND 31)
    , etl_load_ts     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX ON dim_timemonth (year_num, month_num);

-- 3.2) City dimension (Country → City)
CREATE TABLE dim_city (
    city_key        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
    , country_name    VARCHAR(255) NOT NULL
    , city_name       VARCHAR(255) NOT NULL
    , region_name     VARCHAR(255)
    , population      INT
    , latitude        DECIMAL(10,4)
    , longitude       DECIMAL(10,4)
    , etl_load_ts     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT uc_dim_city UNIQUE (country_name, city_name)
);

-- 3.3) Param dimension (Purpose → Category → Param)
CREATE TABLE dim_param (
    param_key   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
    , param_name  VARCHAR(255) NOT NULL
    , param_code  VARCHAR(255)                -- optional nullable
    , category        VARCHAR(255) NOT NULL   -- e.g., Gas, PM, etc.
    , purpose         VARCHAR(50)  NOT NULL   -- per OLTP
    , unit            VARCHAR(255) NOT NULL
    , etl_load_ts     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT uc_dim_param UNIQUE (param_name)
);

-- 3.4) Peak alert level dimension (derived, fixed set)
-- Keys are fixed so they can be meaningfully sorted in tools and FKs stay stable.
CREATE TABLE dim_alertpeak (
    alertpeak_key       INT PRIMARY KEY  -- 1000..1004
    , alert_level_name    VARCHAR(50) NOT NULL  -- None, Yellow, Orange, Red, Crimson
    , alert_rank          SMALLINT NOT NULL     -- same as key for natural ordering
    , etl_load_ts         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT uc_alertpeak UNIQUE (alert_level_name)
    , CONSTRAINT ck_alertpeak_key CHECK (alertpeak_key BETWEEN 1000 AND 1004)
);

-- =========================
-- 4) CREATE TABLE statements for the FACT
-- =========================
CREATE TABLE ft_param_city_month (
	ft_pcm_key  INT NOT NULL PRIMARY KEY -- simple surrogate PK for the fact
	-- Foreign keys to dimensions
    , month_key           INT     NOT NULL
    , city_key            BIGINT  NOT NULL
    , param_key           BIGINT  NOT NULL
    , alertpeak_key       INT NOT NULL    -- derived peak alert for the month
    -- Measures
    , reading_events_count    INTEGER NOT NULL CHECK (reading_events_count >= 0)
    , devices_reporting_count INTEGER NOT NULL CHECK (devices_reporting_count >= 0)
    , recordedvalue_avg       NUMERIC(18,6)
    , recordedvalue_p95       NUMERIC(18,6)
    , exceed_days_any         INTEGER NOT NULL CHECK (exceed_days_any >= 0)
    , data_volume_kb_sum      BIGINT  NOT NULL CHECK (data_volume_kb_sum >= 0)
    , data_quality_avg        NUMERIC(18,6)
    , missing_days            INTEGER NOT NULL CHECK (missing_days >= 0)
    , etl_load_ts             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    -- FKs
    , CONSTRAINT uc_ftpcm UNIQUE (month_key, city_key, param_key)
	, CONSTRAINT fk_ft_time      FOREIGN KEY (month_key)         REFERENCES dim_timemonth (month_key)
    , CONSTRAINT fk_ft_city      FOREIGN KEY (city_key)          REFERENCES dim_city (city_key)
    , CONSTRAINT fk_ft_param     FOREIGN KEY (param_key)         REFERENCES dim_param (param_key)
    , CONSTRAINT fk_ft_alertpeak FOREIGN KEY (alertpeak_key)     REFERENCES dim_alertpeak (alertpeak_key)
);

-- Helpful indexes for common OLAP access paths
CREATE INDEX IF NOT EXISTS ix_ft_city           ON ft_param_city_month (city_key);
CREATE INDEX IF NOT EXISTS ix_ft_param          ON ft_param_city_month (param_key);
CREATE INDEX IF NOT EXISTS ix_ft_alertpeak      ON ft_param_city_month (alertpeak_key);
CREATE INDEX IF NOT EXISTS ix_ft_month          ON ft_param_city_month (month_key);
CREATE INDEX IF NOT EXISTS ix_ft_month_param    ON ft_param_city_month (month_key, param_key);
CREATE INDEX IF NOT EXISTS ix_ft_country_alert  ON ft_param_city_month (alertpeak_key, city_key);




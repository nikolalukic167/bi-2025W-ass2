-- Q09: For 2024, show Reading Events by Country Quarter (Top 10 countries).
SET search_path TO dwh2_006;

WITH top_countries AS (
    -- Identify Top 10 countries by total reading events in 2024
    SELECT c.country_name
    FROM ft_param_city_month f
    JOIN dim_timemonth t ON f.month_key = t.month_key
    JOIN dim_city c      ON f.city_key = c.city_key
    WHERE t.year_num = 2024
    GROUP BY c.country_name
    ORDER BY SUM(f.reading_events_count) DESC
    LIMIT 10
)
SELECT 
    c.country_name,
    SUM(CASE WHEN t.quarter_num = 1 THEN f.reading_events_count ELSE 0 END) AS "Q1_Events",
    SUM(CASE WHEN t.quarter_num = 2 THEN f.reading_events_count ELSE 0 END) AS "Q2_Events",
    SUM(CASE WHEN t.quarter_num = 3 THEN f.reading_events_count ELSE 0 END) AS "Q3_Events",
    SUM(CASE WHEN t.quarter_num = 4 THEN f.reading_events_count ELSE 0 END) AS "Q4_Events"
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_city c      ON f.city_key = c.city_key
-- Filter for only the Top 10 countries identified above
JOIN top_countries tc ON c.country_name = tc.country_name
WHERE t.year_num = 2024
GROUP BY c.country_name
ORDER BY (SUM(f.reading_events_count)) DESC;
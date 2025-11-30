-- Q08: For 2024, show Avg Data Quality by Country (countries with > 2000 devices reporting).
SET search_path TO dwh2_006;

SELECT 
    c.country_name,
    ROUND(AVG(f.data_quality_avg), 4) AS avg_data_quality
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_city c      ON f.city_key = c.city_key
WHERE t.year_num = 2024
GROUP BY c.country_name
HAVING SUM(f.devices_reporting_count) >= 2000
ORDER BY avg_data_quality DESC;
-- Q07: For parameter PM10, show Avg Recorded Value and P95 Recorded Value by Country for 2023.
SET search_path TO dwh2_006;

SELECT 
    c.country_name,
    ROUND(AVG(f.recordedvalue_avg), 4) AS avg_recorded_value,
    ROUND(AVG(f.recordedvalue_p95), 4) AS p95_recorded_value
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_city c      ON f.city_key = c.city_key
JOIN dim_param p     ON f.param_key = p.param_key
WHERE t.year_num = 2023
  AND p.param_name = 'PM10'
GROUP BY c.country_name
ORDER BY c.country_name;
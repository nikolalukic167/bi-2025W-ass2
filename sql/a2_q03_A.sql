-- Q03: For PM10 in 2024, show the total Exceed Days (any) by City.
SET search_path TO dwh2_006;

SELECT 
    c.city_name,
    SUM(f.exceed_days_any) AS total_exceed_days_2024
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_city c      ON f.city_key = c.city_key
JOIN dim_param p     ON f.param_key = p.param_key
WHERE t.year_num = 2024
  AND p.param_name = 'PM10'
GROUP BY c.city_name
ORDER BY total_exceed_days_2024 DESC;
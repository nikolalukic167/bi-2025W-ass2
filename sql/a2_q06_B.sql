-- Q06: For 2024, list the Top 10 Cities by total Missing Days (all parameters).
SET search_path TO dwh2_006;

SELECT 
    c.city_name,
    SUM(f.missing_days) AS total_missing_days_2024
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_city c      ON f.city_key = c.city_key
WHERE t.year_num = 2024
GROUP BY c.city_name
ORDER BY total_missing_days_2024 DESC
LIMIT 10;
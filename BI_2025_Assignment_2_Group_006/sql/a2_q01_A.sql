-- Q01: For parameter PM2, show Exceed Days (any) by Country Month for Q1 of 2024.
SET search_path TO dwh2_006;

SELECT 
    c.country_name,
    SUM(CASE WHEN t.month_num = 1 THEN f.exceed_days_any ELSE 0 END) AS "Jan_Exceed",
    SUM(CASE WHEN t.month_num = 2 THEN f.exceed_days_any ELSE 0 END) AS "Feb_Exceed",
    SUM(CASE WHEN t.month_num = 3 THEN f.exceed_days_any ELSE 0 END) AS "Mar_Exceed"
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_city c      ON f.city_key = c.city_key
JOIN dim_param p     ON f.param_key = p.param_key
WHERE t.year_num = 2024 
  AND t.quarter_num = 1
  AND p.param_name = 'PM2'
GROUP BY c.country_name
ORDER BY c.country_name;
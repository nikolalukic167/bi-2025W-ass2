-- Q02: For parameter O3, show Missing Days in Austria by City Month for Q1 of 2023.
SET search_path TO dwh2_006;

SELECT 
    c.city_name,
    SUM(CASE WHEN t.month_num = 1 THEN f.missing_days ELSE 0 END) AS "Jan_Missing",
    SUM(CASE WHEN t.month_num = 2 THEN f.missing_days ELSE 0 END) AS "Feb_Missing",
    SUM(CASE WHEN t.month_num = 3 THEN f.missing_days ELSE 0 END) AS "Mar_Missing"
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_city c      ON f.city_key = c.city_key
JOIN dim_param p     ON f.param_key = p.param_key
WHERE t.year_num = 2023 
  AND t.quarter_num = 1
  AND p.param_name = 'O3'
  AND c.country_name = 'Austria'
GROUP BY c.city_name
ORDER BY c.city_name;
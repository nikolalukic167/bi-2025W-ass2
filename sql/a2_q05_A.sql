-- Q05: For 2023 and 2024, show total Data Volume (KB) by Param Category Year.
SET search_path TO dwh2_006;

SELECT 
    p.category,
    SUM(CASE WHEN t.year_num = 2023 THEN f.data_volume_kb_sum ELSE 0 END) AS "Vol_2023_KB",
    SUM(CASE WHEN t.year_num = 2024 THEN f.data_volume_kb_sum ELSE 0 END) AS "Vol_2024_KB"
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_param p     ON f.param_key = p.param_key
WHERE t.year_num IN (2023, 2024)
GROUP BY p.category
ORDER BY p.category;
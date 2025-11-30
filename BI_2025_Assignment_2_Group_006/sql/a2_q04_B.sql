-- Q04: For 2024, show total Data Volume (KB) by Region Quarter.
SET search_path TO dwh2_006;

SELECT 
    c.region_name,
    SUM(CASE WHEN t.quarter_num = 1 THEN f.data_volume_kb_sum ELSE 0 END) AS "Q1_Vol_KB",
    SUM(CASE WHEN t.quarter_num = 2 THEN f.data_volume_kb_sum ELSE 0 END) AS "Q2_Vol_KB",
    SUM(CASE WHEN t.quarter_num = 3 THEN f.data_volume_kb_sum ELSE 0 END) AS "Q3_Vol_KB",
    SUM(CASE WHEN t.quarter_num = 4 THEN f.data_volume_kb_sum ELSE 0 END) AS "Q4_Vol_KB"
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_city c      ON f.city_key = c.city_key
WHERE t.year_num = 2024
GROUP BY c.region_name
ORDER BY c.region_name;
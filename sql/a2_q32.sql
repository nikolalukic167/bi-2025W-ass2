-- Q32: 2024 — Top 10 Cities by Data Volume (KB) for category 'Volatile Organic Compound'
SET search_path TO dwh2_xxx;

SELECT
  c.city_name,
  SUM(f.data_volume_kb_sum) AS "Data Volume (KB) 2024"
FROM ft_param_city_month AS f
JOIN dim_timemonth AS t ON t.month_key = f.month_key
JOIN dim_city      AS c ON c.city_key  = f.city_key
JOIN dim_param     AS p ON p.param_key = f.param_key
WHERE t.year_num = 2024
  AND p.category = 'Volatile Organic Compound'
GROUP BY c.city_key, c.city_name
HAVING SUM(f.data_volume_kb_sum) > 0
ORDER BY "Data Volume (KB) 2024" DESC
LIMIT 10;
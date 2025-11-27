-- Q31: O3 — Top 10 Cities by P95 Recorded Value for 2023
SET search_path TO dwh2_xxx;

WITH p95_2023 AS (
  SELECT
    c.city_name,
    AVG(f.recordedvalue_p95) AS p95_recorded_value_2023
  FROM ft_param_city_month AS f
  JOIN dim_timemonth AS t ON t.month_key = f.month_key
  JOIN dim_city      AS c ON c.city_key  = f.city_key
  JOIN dim_param     AS p ON p.param_key = f.param_key
  WHERE t.year_num = 2023
    AND p.param_name = 'O3'
    AND f.recordedvalue_p95 IS NOT NULL
  GROUP BY c.city_name
)
SELECT
  city_name,
  ROUND(p95_recorded_value_2023, 2) AS "P95 Recorded Value (2023)"
FROM p95_2023
ORDER BY p95_recorded_value_2023 DESC
LIMIT 10;


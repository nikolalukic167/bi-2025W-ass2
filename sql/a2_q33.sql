-- Q33: PM4 — per Country, the Month with the highest Avg Data Quality in 2024 (2 decimals)
SET search_path TO dwh2_xxx;

WITH country_month AS (
  SELECT
    c.country_name,
    t.month_name,
    t.month_num,
    AVG(f.data_quality_avg) AS avg_dq_2024
  FROM ft_param_city_month AS f
  JOIN dim_timemonth AS t ON t.month_key = f.month_key
  JOIN dim_city      AS c ON c.city_key  = f.city_key
  JOIN dim_param     AS p ON p.param_key = f.param_key
  WHERE t.year_num = 2024
    AND p.param_name = 'PM4'
    AND f.data_quality_avg IS NOT NULL
  GROUP BY c.country_name, t.month_name, t.month_num
)
SELECT
  country_name,
  month_name,
  ROUND(avg_dq_2024, 2) AS "Avg Data Quality"
FROM (
  SELECT
    country_name,
    month_name,
    month_num,
    avg_dq_2024,
    ROW_NUMBER() OVER (
      PARTITION BY country_name
      ORDER BY avg_dq_2024 DESC NULLS LAST
    ) AS rn
  FROM country_month
) s
WHERE rn = 1
ORDER BY country_name;

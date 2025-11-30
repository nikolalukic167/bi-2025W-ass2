-- Q10: For 2024, list the Top 10 Countries by Avg Data Quality.
SET search_path TO dwh2_006;

SELECT 
    c.country_name,
    AVG(f.data_quality_avg) AS avg_data_quality_2024
FROM ft_param_city_month f
JOIN dim_timemonth t ON f.month_key = t.month_key
JOIN dim_city c      ON f.city_key = c.city_key
WHERE t.year_num = 2024
GROUP BY c.country_name
ORDER BY avg_data_quality_2024 DESC
LIMIT 10;
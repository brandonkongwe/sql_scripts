USE restaurant_db;

-- creating an index on the CAMIS and BORO columns to improve query performance
CREATE INDEX camis_idx ON inspections (CAMIS);
CREATE INDEX boro_idx ON inspections (BORO);
CREATE INDEX cuisine_idx ON inspections (CUISINE_DESCRIPTION);

-- top 10 rows
SELECT TOP 10 * 
FROM inspections;

-- checking data structure and quality
SELECT COUNT(*) AS total_records, 
	   COUNT(DISTINCT CAMIS) AS unique_restaurants,
	   COUNT(*) - COUNT(DISTINCT CAMIS) AS duplicate_inspections,
	   COUNT(DISTINCT BORO) AS boroughs,
	   COUNT(DISTINCT CUISINE_DESCRIPTION) AS cuisine_types
FROM inspections;

-- inspection date ranges
SELECT MIN(inspection_date) AS oldest_date, MAX(inspection_date) AS newest_date
FROM inspections;


-- identifying missing values
SELECT 'CAMIS' AS column_name, COUNT(*) - COUNT(CAMIS) AS null_count,
	   ROUND(100.0 * (COUNT(*) - COUNT(CAMIS)) / COUNT(*), 2) AS null_percentage
FROM inspections
UNION ALL
SELECT 'DBA', COUNT(*) - COUNT(DBA), ROUND(100.0 * (COUNT(*) - COUNT(DBA)) / COUNT(*), 2)
FROM inspections
UNION ALL
SELECT 'BORO', COUNT(*) - COUNT(BORO), ROUND(100.0 * (COUNT(*) - COUNT(BORO)) / COUNT(*), 2)
FROM inspections
UNION ALL
SELECT 'ZIPCODE', COUNT(*) - COUNT(ZIPCODE), ROUND(100.0 * (COUNT(*) - COUNT(ZIPCODE)) / COUNT(*), 2)
FROM inspections
UNION ALL
SELECT 'CUISINE_DESCRIPTION', COUNT(*) - COUNT(CUISINE_DESCRIPTION), ROUND(100.0 * (COUNT(*) - COUNT(CUISINE_DESCRIPTION)) / COUNT(*), 2)
FROM inspections
UNION ALL
SELECT 'INSPECTION_DATE', COUNT(*) - COUNT(INSPECTION_DATE), ROUND(100.0 * (COUNT(*) - COUNT(INSPECTION_DATE)) / COUNT(*), 2)
FROM inspections
UNION ALL
SELECT 'SCORE', COUNT(*) - COUNT(SCORE), ROUND(100.0 * (COUNT(*) - COUNT(SCORE)) / COUNT(*), 2)
FROM inspections
UNION ALL
SELECT 'GRADE', COUNT(*) - COUNT(GRADE), ROUND(100.0 * (COUNT(*) - COUNT(GRADE)) / COUNT(*), 2)
FROM inspections
ORDER BY null_count DESC;

-- creating new fields for analysis
ALTER TABLE inspections
ADD inspection_year AS YEAR(INSPECTION_DATE),
	inspection_month AS MONTH(INSPECTION_DATE),
	inspection_quarter AS DATEPART(QUARTER, INSPECTION_DATE),
	days_since_inspection AS DATEDIFF(DAY, INSPECTION_DATE, GETDATE());


-- standardizing phone numbers to USA format i.e., (555) 555-1234
UPDATE inspections 
SET PHONE = CASE 
    WHEN LEN(PHONE) = 10 THEN 
        '(' + SUBSTRING(PHONE, 1, 3) + ') ' + SUBSTRING(PHONE, 4, 3) + '-' + SUBSTRING(PHONE, 7, 4)
    WHEN LEN(PHONE) = 11 AND LEFT(PHONE, 1) = '1' THEN 
        '(' + SUBSTRING(PHONE, 2, 3) + ') ' + SUBSTRING(PHONE, 5, 3) + '-' + SUBSTRING(PHONE, 8, 4)
    ELSE PHONE
END
WHERE PHONE IS NOT NULL AND ISNUMERIC(REPLACE(PHONE, '-', '')) = 1;


-- creating a cleaned view without placeholder inspection dates 
CREATE VIEW clean_inspections AS 
SELECT *
FROM inspections
WHERE INSPECTION_DATE != '1900-01-01'
	AND INSPECTION_DATE <= GETDATE();


/* query 1: restaurant grade trends over time.
	how have restaurant grades improved or declined over the years? 
*/

SELECT inspection_year, GRADE, COUNT(*) AS inspection_count, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY inspection_year), 2) AS grade_percentage
FROM clean_inspections
WHERE GRADE IN ('A', 'B', 'C')
	AND inspection_year >= 2015
GROUP BY inspection_year, GRADE
ORDER BY inspection_year, GRADE;


/* query 2: borough performance comparison.
	which borough has the highest food safety standards? 
*/

WITH borough_stats AS (
	SELECT BORO,
		COUNT(DISTINCT CAMIS) AS total_restaurants,
		AVG(CAST(SCORE AS FLOAT)) AS avg_score,
		COUNT(CASE WHEN GRADE = 'A' THEN 1 END) AS grade_a_count,
		COUNT(*) AS total_inspections
	FROM clean_inspections
	WHERE SCORE IS NOT NULL AND GRADE IS NOT NULL
	GROUP BY BORO
)
SELECT BORO, total_restaurants,
	ROUND(avg_score, 2) AS average_inspection_score,
	ROUND(100.0 * grade_a_count / total_inspections, 2) AS grade_a_percentage,
	RANK() OVER (ORDER BY avg_score ASC) AS score_rank,
	RANK() OVER (ORDER BY 100.0 * grade_a_count / total_inspections DESC) AS grade_a_rank
FROM borough_stats
ORDER BY average_inspection_score;


/* query 3: cuisine type risk analysis
	which cuisine types are most likely to have food safety violations?
	checking for cuisines with a significant presence in the data (>= 50 records) 
*/

SELECT CUISINE_DESCRIPTION,
	COUNT(DISTINCT CAMIS) AS restaurant_count,
	AVG(CAST(SCORE AS FLOAT)) AS avg_violation_score,
	COUNT(CASE WHEN GRADE = 'A' THEN 1 END) AS grade_a_count,
	COUNT(CASE WHEN GRADE IN ('B', 'C') THEN 1 END) AS poor_grade_count,
	COUNT(*) AS total_inspections,
	ROUND(100.0 * COUNT(CASE WHEN GRADE = 'A' THEN 1 END) / COUNT(*), 2) AS grade_a_rate
FROM clean_inspections
WHERE CUISINE_DESCRIPTION IS NOT NULL
	AND SCORE IS NOT NULL
	AND GRADE IS NOT NULL
GROUP BY CUISINE_DESCRIPTION
HAVING COUNT(DISTINCT CAMIS) >= 50
ORDER BY avg_violation_score DESC;


/* query 4: monthly inspection patterns
	do restaurants perform differently during different months? 
*/

SELECT inspection_month, 
	DATENAME(MONTH, DATEFROMPARTS(2023, inspection_month, 1)) AS month_name,
	COUNT(*) AS inspection_count,
	AVG(CAST(SCORE AS FLOAT)) AS avg_score,
	COUNT(CASE WHEN GRADE = 'A' THEN 1 END) AS grade_a_count,
	ROUND(100.0 * COUNT(CASE WHEN GRADE = 'A' THEN 1 END) / COUNT(*), 2) AS grade_a_percentage
FROM clean_inspections
WHERE SCORE IS NOT NULL AND GRADE IS NOT NULL
GROUP BY inspection_month
ORDER BY inspection_month;


/* query 5: repeat offender analysis
	which restaurants consistently have poor grades?
	checking for restaurants with at least 3 inspections and 2 poor grades 
*/

WITH restaurant_performance AS (
	SELECT CAMIS, DBA, BORO, CUISINE_DESCRIPTION,
		COUNT(*) AS inspection_count,
		AVG(CAST(SCORE AS FLOAT)) AS avg_score,
		COUNT(CASE WHEN GRADE IN ('B', 'C') THEN 1 END) AS poor_grade_count,
		COUNT(CASE WHEN GRADE = 'A' THEN 1 END) AS good_grade_count,
		MAX(INSPECTION_DATE) AS last_inspection
	FROM clean_inspections
	WHERE SCORE IS NOT NULL AND GRADE IS NOT NULL
	GROUP BY CAMIS, DBA, BORO, CUISINE_DESCRIPTION
	HAVING COUNT(*) >= 3
)
SELECT CAMIS, DBA, BORO, CUISINE_DESCRIPTION, inspection_count, ROUND(avg_score, 2) AS average_score,
	poor_grade_count, good_grade_count, ROUND(100.0 * poor_grade_count / inspection_count, 2) as poor_grade_percentage,
	last_inspection
FROM restaurant_performance
WHERE poor_grade_count >= 2
ORDER BY poor_grade_percentage DESC, avg_score DESC;


/* query 6: improvement tracking
	which restaurants have shown the most improvement over time?
	lower score_improvement value shows most improvement 
*/

WITH restaurant_trends AS (
	SELECT CAMIS, DBA, BORO, CUISINE_DESCRIPTION,
		FIRST_VALUE(SCORE) OVER (PARTITION BY CAMIS ORDER BY INSPECTION_DATE) AS first_score,
		LAST_VALUE(SCORE) OVER (PARTITION BY CAMIS ORDER BY INSPECTION_DATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS latest_score,
		FIRST_VALUE(INSPECTION_DATE) OVER (PARTITION BY CAMIS ORDER BY INSPECTION_DATE) AS first_inspection,
		LAST_VALUE(INSPECTION_DATE) OVER (PARTITION BY CAMIS ORDER BY INSPECTION_DATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS latest_inspection,
		COUNT(*) OVER (PARTITION BY CAMIS) AS total_inspections
	FROM clean_inspections
	WHERE SCORE IS NOT NULL
)
SELECT DISTINCT CAMIS, DBA, BORO, CUISINE_DESCRIPTION, first_score, latest_score,
	latest_score - first_score AS score_improvement, 
	first_inspection,
	latest_inspection,
	DATEDIFF(MONTH, first_inspection, latest_inspection) AS months_tracked,
	total_inspections
FROM restaurant_trends
WHERE total_inspections >= 3
	AND DATEDIFF(MONTH, first_inspection, latest_inspection) >= 12
	AND first_score IS NOT NULL
	AND latest_score IS NOT NULL
ORDER BY score_improvement ASC;


/* query 7: violation code analysis
	what are the most common violations and their impact on scores? 
*/

SELECT VIOLATION_CODE, 
	COUNT(*) AS violation_frequency,
	AVG(CAST(SCORE AS FLOAT)) AS avg_score,
	COUNT(CASE WHEN CRITICAL_FLAG = 'Critical' THEN 1 END) AS critical_violations,
	ROUND(100.0 * COUNT(CASE WHEN CRITICAL_FLAG = 'Critical' THEN 1 END) / COUNT(*), 2) AS critical_percentage
FROM clean_inspections
WHERE VIOLATION_CODE IS NOT NULL
	AND SCORE IS NOT NULL
GROUP BY VIOLATION_CODE
HAVING COUNT(*) >= 100
ORDER BY violation_frequency DESC;


/* query 8: geographic hotspot analysis
	which ZIP codes have the highest concentration of poor performing restaurants?
	showing areas with at least 10 restaurants 
*/

SELECT ZIPCODE, BORO,
	COUNT(DISTINCT CAMIS) AS restaurant_count,
	AVG(CAST(SCORE AS FLOAT)) AS avg_score,
	COUNT(CASE WHEN GRADE IN ('B', 'C') THEN 1 END) AS poor_grade_inspections,
	COUNT(*) AS total_inspections,
	ROUND(100.0 * COUNT(CASE WHEN GRADE IN ('B', 'C') THEN 1 END) / COUNT(*), 2) AS poor_grade_rate
FROM clean_inspections
WHERE ZIPCODE IS NOT NULL
	AND SCORE IS NOT NULL
	AND GRADE IS NOT NULL
GROUP BY ZIPCODE, BORO
HAVING COUNT(DISTINCT CAMIS) >= 10
ORDER BY poor_grade_rate DESC, avg_score DESC;


/* query 9: restaurant closure risk prediction
	trying to identifty restaurants that are at risk of closure based on inspection patterns.
*/

WITH risk_factors AS (
	SELECT CAMIS, DBA, BORO, CUISINE_DESCRIPTION,
		COUNT(*) AS inspection_count,
		AVG(CAST(SCORE AS FLOAT)) AS avg_score,
		MAX(INSPECTION_DATE) AS last_inspection,
		COUNT(CASE WHEN GRADE IN ('B', 'C') THEN 1 END) AS poor_grades,
		COUNT(CASE WHEN CRITICAL_FLAG = 'Critical' THEN 1 END) AS critical_violations,
		DATEDIFF(DAY, MAX(INSPECTION_DATE), GETDATE()) AS days_since_last_inspection
	FROM clean_inspections
	WHERE SCORE IS NOT NULL
	GROUP BY CAMIS, DBA, BORO, CUISINE_DESCRIPTION
)
SELECT CAMIS, DBA, BORO, CUISINE_DESCRIPTION, ROUND(avg_score, 2) AS average_score,
	poor_grades, critical_violations, days_since_last_inspection, last_inspection,
	CASE
		WHEN avg_score > 20 AND poor_grades >= 2 AND days_since_last_inspection > 365 THEN 'HIGH RISK'
		WHEN avg_score > 15 AND poor_grades >= 1 AND days_since_last_inspection > 180 THEN 'MEDIUM RISK'
		ELSE 'LOW RISK'
	END AS closure_risk_level
FROM risk_factors
WHERE inspection_count >= 2
ORDER BY
	CASE 
		WHEN avg_score > 20 AND poor_grades >= 2 AND days_since_last_inspection > 365 THEN 1
		WHEN avg_score > 15 AND poor_grades >= 1 AND days_since_last_inspection > 180 THEN 2
		ELSE 3
	END,
	avg_score DESC;


/* query 10: performance benchmarking
	how do restaurants compare to their peers, i.e., same cuisine type in the same borough 
*/

WITH all_scores AS (
    SELECT BORO, CUISINE_DESCRIPTION, CAST(SCORE AS FLOAT) AS score
    FROM clean_inspections
    WHERE SCORE IS NOT NULL
        AND BORO IS NOT NULL
        AND CUISINE_DESCRIPTION IS NOT NULL
),
peer_benchmarks AS (
    SELECT DISTINCT
        BORO, 
        CUISINE_DESCRIPTION,
        AVG(score) OVER (PARTITION BY BORO, CUISINE_DESCRIPTION) AS cuisine_boro_avg_score,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY score) OVER (PARTITION BY BORO, CUISINE_DESCRIPTION) AS score_25th_percentile,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY score) OVER (PARTITION BY BORO, CUISINE_DESCRIPTION) AS score_75th_percentile
    FROM all_scores
),
restaurant_performance AS (
    SELECT r.CAMIS, r.DBA, r.BORO, r.CUISINE_DESCRIPTION,
        AVG(CAST(r.SCORE AS FLOAT)) AS restaurant_avg_score,
        COUNT(*) AS inspection_count
    FROM clean_inspections r
    WHERE r.SCORE IS NOT NULL
    GROUP BY r.CAMIS, r.DBA, r.BORO, r.CUISINE_DESCRIPTION
    HAVING COUNT(*) >= 2
)
SELECT rp.CAMIS, rp.DBA, rp.BORO, rp.CUISINE_DESCRIPTION,
    ROUND(rp.restaurant_avg_score, 2) AS restaurant_score,
    ROUND(pb.cuisine_boro_avg_score, 2) AS peer_average,
    ROUND(rp.restaurant_avg_score - pb.cuisine_boro_avg_score, 2) AS score_vs_peers,
    CASE
        WHEN rp.restaurant_avg_score <= pb.score_25th_percentile THEN 'TOP QUARTILE'
        WHEN rp.restaurant_avg_score <= pb.cuisine_boro_avg_score THEN 'ABOVE AVERAGE'
        WHEN rp.restaurant_avg_score <= pb.score_75th_percentile THEN 'BELOW AVERAGE'
        ELSE 'BOTTOM QUARTILE'
    END AS performance_tier,
    rp.inspection_count
FROM restaurant_performance rp
JOIN peer_benchmarks pb ON rp.BORO = pb.BORO AND rp.CUISINE_DESCRIPTION = pb.CUISINE_DESCRIPTION
ORDER BY rp.BORO, rp.CUISINE_DESCRIPTION, rp.restaurant_avg_score;
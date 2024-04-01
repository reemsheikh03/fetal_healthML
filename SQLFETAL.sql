-- Step 1: Calculate mean and standard deviation of baseline value
USE FetalHealth2
DECLARE @mean FLOAT
DECLARE @stddev FLOAT

SELECT @mean = AVG([baseline value]), @stddev = STDEV([baseline value])
FROM dbo.fetal_health;

-- Step 2: Classify the data into normal, suspect, and pathological
IF OBJECT_ID('tempdb..#temp_classified_fetal_health') IS NOT NULL
    DROP TABLE #temp_classified_fetal_health;

SELECT 
    CASE 
        WHEN [baseline value] < (@mean - @stddev * 2) THEN 'Pathological'
        WHEN [baseline value] > (@mean + @stddev) THEN 'Suspect'
        ELSE 'Normal'
    END AS health_status,
    *
INTO #temp_classified_fetal_health
FROM dbo.fetal_health;

-- Create table for Normal data
SELECT *
INTO dbo.new1_normal_fetal_health
FROM #temp_classified_fetal_health
WHERE health_status = 'Normal';

-- Create table for Suspect data
SELECT *
INTO dbo.new1_suspect_fetal_health
FROM #temp_classified_fetal_health
WHERE health_status = 'Suspect';

-- Create table for Pathological data
SELECT *
INTO dbo.new1_pathological_fetal_health
FROM #temp_classified_fetal_health
WHERE health_status = 'Pathological';

-- Step 3: Retrieve summary statistics for each column in each dataset
SELECT 
    health_status,
    COUNT(*) AS total_count,
    AVG(accelerations) AS mean_accelerations,
    AVG(fetal_movement) AS mean_fetal_movement,
    AVG(uterine_contractions) AS mean_uterine_contractions,
    AVG(light_decelerations) AS mean_light_decelerations,
    AVG(severe_decelerations) AS mean_severe_decelerations,
    AVG(prolongued_decelerations) AS mean_prolongued_decelerations,
    AVG(abnormal_short_term_variability) AS mean_abnormal_short_term_variability,
    AVG(mean_value_of_short_term_variability) AS mean_mean_value_of_short_term_variability,
    AVG(percentage_of_time_with_abnormal_long_term_variability) AS mean_percentage_of_time_with_abnormal_long_term_variability,
    AVG(mean_value_of_long_term_variability) AS mean_mean_value_of_long_term_variability,
    AVG(histogram_width) AS mean_histogram_width,
    AVG(histogram_min) AS mean_histogram_min,
    AVG(histogram_max) AS mean_histogram_max,
    AVG(histogram_number_of_peaks) AS mean_histogram_number_of_peaks,
    AVG(histogram_number_of_zeroes) AS mean_histogram_number_of_zeroes,
    AVG(histogram_mode) AS mean_histogram_mode,
    AVG(histogram_mean) AS mean_histogram_mean,
    AVG(histogram_median) AS mean_histogram_median,
    AVG(histogram_variance) AS mean_histogram_variance,
    AVG(histogram_tendency) AS mean_histogram_tendency
FROM #temp_classified_fetal_health
GROUP BY health_status;

-- Drop temporary table
DROP TABLE #temp_classified_fetal_health;

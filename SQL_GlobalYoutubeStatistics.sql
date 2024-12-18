

select *
from GlobalYouTubeStatistics

-- CREATE STAGING TABLE

select *
into GlobalYouTubeStatistics_staging
from GlobalYouTubeStatistics
where 1 = 0;

insert into GlobalYouTubeStatistics_staging
select * from GlobalYouTubeStatistics;


-- 1. REMOVE DUPLICATES

select *
from GlobalYouTubeStatistics_staging

 
 -- Identification Duplicates

SELECT 
    [rank], [Youtuber], [subscribers], [video views], [category], [Title], 
    [uploads], [Country], [Abbreviation], [channel_type], 
    [video_views_rank], [country_rank], [channel_type_rank], 
    [video_views_for_the_last_30_days], [lowest_monthly_earnings], [highest_monthly_earnings], 
    [lowest_yearly_earnings], [highest_yearly_earnings], [subscribers_for_last_30_days], 
    [created_year], [created_month], [created_date], [Gross tertiary education enrollment (%)], 
    [Population], [Unemployment rate], [Urban_population], [Latitude], [Longitude], 
    COUNT(*) AS duplicate_count
FROM GlobalYoutubeStatistics_staging
GROUP BY 
    [rank], [Youtuber], [subscribers], [video views], [category], [Title], 
    [uploads], [Country], [Abbreviation], [channel_type], 
    [video_views_rank], [country_rank], [channel_type_rank], 
    [video_views_for_the_last_30_days], [lowest_monthly_earnings], [highest_monthly_earnings], 
    [lowest_yearly_earnings], [highest_yearly_earnings], [subscribers_for_last_30_days], 
    [created_year], [created_month], [created_date], [Gross tertiary education enrollment (%)], 
    [Population], [Unemployment rate], [Urban_population], [Latitude], [Longitude]
HAVING COUNT(*) > 1;

-- data is clean of duplicates
-- Next step



-- 2. Standardize Data

SELECT *
FROM GlobalYouTubeStatistics_staging
WHERE Youtuber LIKE '%�%';

SELECT COUNT(*) AS Total, 
       SUM(CASE WHEN [Youtuber] LIKE '%�%' OR [Title] LIKE '%�%' THEN 1 ELSE 0 END) AS Affected
FROM GlobalYouTubeStatistics_staging;

SELECT 
    (SUM(CASE WHEN [Youtuber] LIKE '%�%' OR [Title] LIKE '%�%' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS Damage_Percentage
FROM GlobalYouTubeStatistics_staging;



-- Since the broken data row is only 10%, we will delete the data row

DELETE FROM GlobalYouTubeStatistics_staging
WHERE [Youtuber] LIKE '%�%' OR [Title] LIKE '%�%';



-- Standardization to ensure Youtuber and Title column strings and encoding are stored correctly

UPDATE GlobalYouTubeStatistics_staging
SET [Youtuber] = REPLACE([Youtuber], '�', ''),
    [Title] = REPLACE([Title], '�', '');


SELECT DISTINCT [Youtuber], [Title]
FROM GlobalYouTubeStatistics_staging
WHERE [Youtuber] LIKE '%�%' OR [Title] LIKE '%�%';


select *
from GlobalYouTubeStatistics_staging



-- Identify the 'nan' row

SELECT 
    COUNT(*) AS Nan_Count
FROM 
    GlobalYouTubeStatistics_staging
WHERE 
    Country = 'nan';


SELECT 
    COUNT(*) AS Nan_Count
FROM 
    GlobalYouTubeStatistics_staging
WHERE 
    category = 'nan';


SELECT 
    COUNT(*) AS Nan_Count
FROM 
    GlobalYouTubeStatistics_staging
WHERE 
    Abbreviation = 'nan';


SELECT 
    COUNT(*) AS Nan_Count
FROM 
    GlobalYouTubeStatistics_staging
WHERE 
    channel_type = 'nan';


-- Replacing the 'nan' row with 'Unknown'

UPDATE GlobalYouTubeStatistics_staging
SET Category = 'Unknown'
WHERE Category = 'nan';


UPDATE GlobalYouTubeStatistics_staging
SET Country = 'Unknown'
WHERE Country = 'nan';


UPDATE GlobalYouTubeStatistics_staging
SET Abbreviation = 'Unknown'
WHERE Abbreviation = 'nan';


UPDATE GlobalYouTubeStatistics_staging
SET channel_type = 'Unknown'
WHERE channel_type = 'nan';


select *
from GlobalYouTubeStatistics_staging



-- Data has been standardized




-- Exploratory Data Analysis (EDA)

-- 1. Youtube Channel Popularity and Performance

SELECT 
    [Youtuber],
    [subscribers],
    [video views],
    [uploads],
    ([subscribers] * 0.6 + [video views] * 0.3 + [uploads] * 0.1) AS Popularity_Score
FROM 
    GlobalYouTubeStatistics_staging
ORDER BY 
    Popularity_Score DESC;

SELECT 
    [Youtuber],
    [video views],
    [uploads],
    [subscribers],
    CASE WHEN [uploads] > 0 THEN [video views] / [uploads] ELSE 0 END AS Views_Per_Upload,
    CASE WHEN [subscribers] > 0 THEN [video views] / [subscribers] ELSE 0 END AS Views_Per_Subscriber
FROM 
    GlobalYouTubeStatistics_staging
ORDER BY 
    Views_Per_Upload DESC, Views_Per_Subscriber DESC;



-- 2. Channel Categories and Types

SELECT 
    [category],
    COUNT(*) AS Total_Channels,
    AVG([subscribers]) AS Avg_Subscribers,
    AVG([video views]) AS Avg_Video_Views,
    AVG([uploads]) AS Avg_Uploads
FROM 
    GlobalYouTubeStatistics_staging
GROUP BY 
    [category]
ORDER BY 
    Avg_Subscribers DESC;

SELECT 
    [channel_type],
    COUNT(*) AS Total_Channels,
    AVG([video views]) AS Avg_Video_Views,
    AVG([uploads]) AS Avg_Uploads,
    AVG(([lowest_monthly_earnings] + [highest_monthly_earnings]) / 2) AS Avg_Monthly_Earnings,
    AVG(([lowest_yearly_earnings] + [highest_yearly_earnings]) / 2) AS Avg_Yearly_Earnings
FROM 
    GlobalYouTubeStatistics_staging
GROUP BY 
    [channel_type]
ORDER BY 
    Avg_Yearly_Earnings DESC;



-- 3. Location and Gegraphy

SELECT 
    [Country],
    SUM([subscribers]) AS Total_Subscribers,
    SUM([video views]) AS Total_Views,
    COUNT(*) AS Total_Channels
FROM 
    GlobalYouTubeStatistics_staging
GROUP BY 
    [Country]
ORDER BY 
    Total_Subscribers DESC;



-- 4. Revenue and Finance

SELECT 
    [Youtuber],
    [lowest_monthly_earnings],
    [highest_monthly_earnings],
    [lowest_yearly_earnings],
    [highest_yearly_earnings],
    ([lowest_monthly_earnings] + [highest_monthly_earnings]) / 2 AS Avg_Monthly_Earnings,
    ([lowest_yearly_earnings] + [highest_yearly_earnings]) / 2 AS Avg_Yearly_Earnings
FROM 
    GlobalYouTubeStatistics_staging
ORDER BY 
    Avg_Yearly_Earnings DESC;












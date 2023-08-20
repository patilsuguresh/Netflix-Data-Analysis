/*Project 2: Data cleaning and analysis for Netflix using SQL 
Segment 1: Database - Tables, Columns, Relationships
Q1) Identify the tables in the dataset and their respective columns.
Have to identify the table and column names*/
DESCRIBE netflix

/*Q2) Determine the number of rows in each table within the schema.
Have to find how many number rows present in the dataset*/;
SELECT COUNT(*) FROM netflix;
/* There are 8790 rows in the dataset*/

/*Q3) Identify and handle any missing values in the dataset.
To check if there are any missing or null values in the dataset*/
SELECT * FROM netflix
WHERE id IS NULL OR show_id IS NULL OR type IS NULL OR title IS NULL or director IS NULL or country IS NULL OR date_added IS NULL or release_year IS NULL or rating IS NULL or duration IS NULL 
or listed_in IS NULL;

/*Segment 2: Content Analysis
Q1) Analyse the distribution of content types (movies vs. TV shows) in the dataset.
We basically have to find which content distrubuted more in Movies and TV Shows*/
SELECT 
        type as "Content Type",
        COUNT(*) as "Total Count",
        CONCAT(ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM netflix)),'%') 
        as   Total_percentage 
FROM netflix
        GROUP BY 1;
        
/*Q2) In this we have to find the 10 countries that are with highest number of productions on netflix*/
SELECT country, count(*) AS production_count
from netflix GROUP BY country ORDER BY production_count DESC LIMIT 10;

/*Q3) Investigate the trend of content additions over the years.
We have to find tredning content from when the content added to netflix based on their views, rating, release year.
from 2017 to 2021 the trending is growing*/
SELECT YEAR(str_to_date(date_added, '%m/%d/%Y')) AS YEAR,
count(*) AS NUMBER_OF_CONTENT FROM netflix
GROUP BY YEAR ORDER BY YEAR DESC;

/*Q4) Analyse the relationship between content duration and release year.
To analyze the connectivity between duration and release year of content*/
SELECT release_year, AVG(duration) AS Watch_Time
FROM netflix GROUP BY release_year ORDER BY release_year DESC;

/*Q5)I dentify the directors with the most content on Netflix.
To find the director who directed more content that are on Netflix*/
SELECT director, COUNT(*) AS content_count
FROM netflix GROUP BY director
ORDER BY content_count DESC LIMIT 10;

/*Segment 3: Genre and Category Analysis
Q1) Determine the unique genres and categories present in the dataset.
To find unique/distinct genres and categories of dataset*/
SELECT DISTINCT listed_in AS Genre, type AS Category
FROM Netflix ORDER BY Category;

/*Q2) Calculate the percentage of movies and TV shows in each genre.
To find how many no of movies and TV shows released in each genre*/
SELECT listed_in AS Genre,
       SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS Movies,
       SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS TV_Shows,
       COUNT(*) AS total_count,
       (SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS Percentage_of_Movies,
       (SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS Percentage_of_TV_Shows
FROM Netflix
GROUP BY listed_in ORDER BY Genre;

/*Q3) Identify the most popular genres/categories based on the number of productions.
To find popular/fame Genres/categories based on their production number*/
SELECT listed_in AS Genre,
COUNT(*) AS No_of_Productions
FROM Netflix
GROUP BY listed_in
ORDER BY No_of_Productions DESC 
LIMIT 30;

/*Q4) Calculate the cumulative sum of content duration within each genre.
To find total sum of watch time or duration in each genre*/
SELECT listed_in AS Genre,
SUM(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)) AS cumulative_duration
FROM Netflix
GROUP BY listed_in ORDER BY Genre;

/*Segment 4: Release Date Analysis
Q1) Determine the distribution of content releases by month and year.
To find no of distributions of content upon their month and year*/
SELECT MONTH(STR_TO_DATE(date_added, '%m/%d/%Y')) AS Month,
YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS Year, COUNT(*) AS count
FROM Netflix
WHERE date_added IS NOT NULL
GROUP BY Month, year;

/*Q2) Analyse the seasonal patterns in content releases. 
To find the season of content based on which more no of releases happend*/
SELECT MONTH(STR_TO_DATE(date_added, '%m/%d/%Y')) AS Month,
YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS Year,
COUNT(*) AS Count FROM Netflix
WHERE date_added IS NOT NULL
GROUP BY Month, Year
ORDER BY Count DESC;

/*Q3) Identify the months and years with the highest number of releases.
To find in which month and year did the highest number of releases took place*/
SELECT MONTH(STR_TO_DATE(date_added, '%m/%d/%Y')) AS Month,
YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS Year,
COUNT(*) AS Highest_release
FROM Netflix
WHERE date_added IS NOT NULL
GROUP BY Month, Year
ORDER BY Highest_release DESC;


/* Segment 5: Rating Analysis
Q1) Investigate the distribution of ratings across different genres.
To find the ratings of distribution ratings of genres*/
SELECT listed_in, rating, COUNT(*) AS Rating
FROM netflix GROUP BY listed_in, rating
ORDER BY Rating DESC;

/*Q2) Analyse the relationship between ratings and content duration.
To find how rating and content duration are related*/
SELECT rating, AVG(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)) AS Watch_Time
FROM Netflix WHERE duration LIKE '%min'
GROUP BY rating ORDER BY Watch_Time DESC;

/*Segment 6: Co-occurrence Analysis
Q1) Identify the most common pairs of genres/categories that occur together in content.
To find common pairs of genre/category that occurs together in content*/
SELECT t1.listed_in AS genre1, t2.listed_in AS genre2, COUNT(*) AS count
FROM Netflix AS t1
JOIN Netflix AS t2 ON t1.show_id <> t2.show_id AND t1.listed_in < t2.listed_in
GROUP BY t1.listed_in, t2.listed_in
ORDER BY count DESC;
SELECT * FROM
(
SELECT distinct type,listed_in,
count(*) OVER (PARTITION BY type, listed_in) AS count
FROM netflix
) t
where count>1
ORDER BY type, listed_in;

/*Q2) Analyse the relationship between genres/categories and content duration.*/
SELECT * FROM
(
SELECT Distinct type AS Movie_TV_Show, listed_in AS Genre,
count(*) OVER (PARTITION BY type, listed_in) AS Occurance
FROM netflix
) t
WHERE Occurance > 1
ORDER BY Movie_TV_Show, Genre;

/*Segment 7: International Expansion Analysis
Q1) Identify the countries where Netflix has expanded its content offerings.
To find the countries where Netflix is available*/
SELECT distinct country
FROM netflix WHERE date_added IS NOT NULL;

/*Q2) Analyse the distribution of content types in different countries.
To lookout for content distribution type based on country*/
SELECT country, type, COUNT(*) AS No_of_Content
FROM netflix
GROUP BY country, type
ORDER BY country, No_of_Content DESC;

/*Q3) Investigate the relationship between content duration and country of production.
To find connecticity between watchtime/content duration and country of production to get where content getting more ratings*/
SELECT Country,
       AVG(CASE WHEN type = 'Movie' THEN duration_minutes END) AS Movie_Duration,
       AVG(CASE WHEN type = 'TV Show' THEN duration_seasons END) AS TV_Show_Duration
FROM (
    SELECT *,
           CASE WHEN type = 'Movie' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) END AS Duration_Minutes,
           CASE WHEN type = 'TV Show' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) END AS Duration_Seasons
    FROM netflix
) AS data 
GROUP BY Country;

/*Segment 8: Recommendations for Content Strategy
Q1) Based on the analysis, provide recommendations for the types of content Netflix
Recommendations for the types of content Netflix should focus on producing where the content watch time is more and ratings are higher based on requirement of content.*/
SELECT listed_in, COUNT(*) AS Content 
FROM Netflix GROUP BY listed_in ORDER BY Content DESC;

/*Q2) Identify potential areas for expansion and growth based on the analysis of the dataset.
Potential areas for expansion and growth based on the analysis of the dataset are as follows.*/
SELECT country, COUNT(*) AS Country_Count
FROM Netflix
WHERE country IS NOT NULL
GROUP BY country 
ORDER BY Country_Count DESC LIMIT 10;










 





















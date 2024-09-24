# Fresh-Segments-SQL-Challenge-Case-Study-3
<p align = "center">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/8.png" width="43%" height="43%">
</p>

In this repository, you will find my solutions for the 3rd challenge of [8 Week Challenge](https://8weeksqlchallenge.com/) which is [Fresh-Segments](https://8weeksqlchallenge.com/case-study-8/) Challenge.
## Table of Content
1. [Business Case](#business-case)
2. [Available Data](#available-data)
3. [Questions and Solutions](#questions-and-solutions)

## Business Case
Danny created Fresh Segments, a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.

Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.

In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.

Danny has asked for your assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests

## Available Data
The data available for this project consists of two tables:

### `interest_metrics` table 
<Details>
    <summary>Table Details</summary>
&nbsp;
  
|_month|_year|month_year|interest_id|composition|index_value|ranking|percentile_ranking|
|------|-----|----------|-----------|-----------|-----------|-------|------------------|
|7     |2018 |07-2018   |32486      |11.89      |6.19       |1      |99.86             |
|7     |2018 |07-2018   |6106       |9.93       |5.31       |2      |99.73             |
|7     |2018 |07-2018   |18923      |10.85      |5.29       |3      |99.59             |
|7     |2018 |07-2018   |6344       |10.32      |5.1        |4      |99.45             |
|7     |2018 |07-2018   |100        |10.77      |5.04       |5      |99.31             |
|7     |2018 |07-2018   |69         |10.82      |5.03       |6      |99.18             |
|7     |2018 |07-2018   |79         |11.21      |4.97       |7      |99.04             |
|7     |2018 |07-2018   |6111       |10.71      |4.83       |8      |98.9              |
|7     |2018 |07-2018   |6214       |9.71       |4.83       |8      |98.9              |
|7     |2018 |07-2018   |19422      |10.11      |4.81       |10     |98.63             |


* This table contains information about aggregated interest metrics for a specific major client of Fresh Segments which makes up a large proportion of their customer base.
* Each record in this table represents the performance of a specific `interest_id` based on the client’s customer base interest measured through clicks and interactions with specific targeted advertising content.
* If we look at the first row:
In July 2018, the `composition` metric is 11.89, meaning that 11.89% of the client’s customer list interacted with the interest `interest_id` = 32486 - we can link `interest_id` to a separate mapping table to find the segment name called “Vacation Rental Accommodation Researchers”


* The `index_value` is 6.19, means that the `composition` value is 6.19x the average composition value for all Fresh Segments clients’ customer for this particular interest in the month of July 2018.

* The `ranking` and `percentage_ranking` relates to the order of `index_value` records in each month year.

</Details>

### `interest_map` table
<Details>
    <summary>Table Details</summary>
&nbsp; 

|id   |interest_name|interest_summary|created_at|last_modified|
|-----|-------------|----------------|----------|-------------|
|1    |Fitness Enthusiasts|Consumers using fitness tracking apps and websites.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|2    |Gamers       |Consumers researching game reviews and cheat codes.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|3    |Car Enthusiasts|Readers of automotive news and car reviews.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|4    |Luxury Retail Researchers|Consumers researching luxury product reviews and gift ideas.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|5    |Brides & Wedding Planners|People researching wedding ideas and vendors.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|6    |Vacation Planners|Consumers reading reviews of vacation destinations and accommodations.|2016-05-26 14:57:59|2018-05-23 11:30:13|
|7    |Motorcycle Enthusiasts|Readers of motorcycle news and reviews.|2016-05-26 14:57:59|2018-05-23 11:30:13|
|8    |Business News Readers|Readers of online business news content.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|12   |Thrift Store Shoppers|Consumers shopping online for clothing at thrift stores and researching locations.|2016-05-26 14:57:59|2018-03-16 13:14:00|
|13   |Advertising Professionals|People who read advertising industry news.|2016-05-26 14:57:59|2018-05-23 11:30:12|

* This mapping table links the interest_id with their relevant interest information.
</Details>

## Questions and Solutions

### Section A: Data Exploration and Cleansing
#### 1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month

* First: We should drop the current month_year column
  -- add a new column with date type 
```sql
    ALTER TABLE interest_metrics
     DROP COLUMN month_year;
```
* Add a new column with date type
```sql
    ALTER TABLE interest_metrics add month_year date;
```
* Then, concat month and year with the first day of each month in the new column 
```sql
   UPDATE interest_metrics
      SET month_year = CAST(concat (_year, '-', 0, _month, '-', 01) AS date)
    WHERE _month != 'NULL'
      AND _year != 'NULL';
```
|_month|_year|interest_id|composition|index_value|ranking|percentile_ranking|month_year|
|------|-----|-----------|-----------|-----------|-------|------------------|----------|
|7     |2018 |32486      |11.89      |6.19       |1      |99.86             |2018-07-01|
|7     |2018 |6106       |9.93       |5.31       |2      |99.73             |2018-07-01|
|7     |2018 |18923      |10.85      |5.29       |3      |99.59             |2018-07-01|
|7     |2018 |6344       |10.32      |5.1        |4      |99.45             |2018-07-01|
|7     |2018 |100        |10.77      |5.04       |5      |99.31             |2018-07-01|
|7     |2018 |69         |10.82      |5.03       |6      |99.18             |2018-07-01|
                                                                                                                                                                                 
#### 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
```sql
   SELECT month_year,
          COUNT(interest_id) AS total_count
     FROM interest_metrics
 GROUP BY month_year
 ORDER BY total_count DESC;
 ```
 |month_year|total_count|
|----------|-----------|
|2019-08-01|1149       |
|2019-03-01|1136       |
|2019-02-01|1121       |
|2019-04-01|1099       |
|2018-12-01|995        |
|2019-01-01|973        |
|2018-11-01|928        |
|2019-07-01|864        |
|2018-10-01|857        |
|2019-05-01|857        |
|2019-06-01|824        |
|2018-09-01|780        |
|2018-08-01|767        |
|2018-07-01|729        |
|NULL      |1          |

#### 3. What do you think we should do with these null values in the fresh_segments.interest_metrics?
* We should check the null values
```sql
  SELECT * 
    FROM interest_metrics 
   WHERE month_year IS NULL;
```
|_month|_year|interest_id|composition|index_value|ranking|percentile_ranking|month_year|
|------|-----|-----------|-----------|-----------|-------|------------------|----------|
|NULL  |NULL |21246      |1.61       |0.68       |1191   |0.25              |NULL      |

* All rows with null values have also null interest_id exept one row, so we should drop them as they are not meaningful
```sql
  DELETE 
    FROM interest_metrics
   WHERE interest_id = 'NULL';
```
#### 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
* We have two solution choices: Either we select the two values seperately, or we make a union (since we do not have outer join in MYSQL) 

  * **The 1st solution**

    ```sql
	   SELECT (SELECT COUNT(DISTINCT interest_id) 
                 FROM interest_metrics
                WHERE interest_id NOT IN (SELECT id FROM interest_map)
              ) AS not_in_map,
              (SELECT COUNT(DISTINCT id) 
                 FROM interest_map
                WHERE id NOT IN (SELECT interest_id FROM interest_metrics)
              ) AS not_in_metrics;
    ```
    |not_in_map|not_in_metric|
    |----------|-------------|
    |0         |7            |

  * **The 2nd solution**

    ```sql
	   SELECT sum(case when id is null then 1 else 0 end) as not_in_map,
		      sum(case when interest_id is null then 1 else 0 end) as not_in_metric
	     FROM (
                SELECT * FROM interest_metrics AS mt LEFT JOIN interest_map mp on mt.interest_id = mp.id 
                UNION 
	            SELECT * FROM interest_metrics AS mt RIGHT JOIN interest_map AS mp ON mt.interest_id = mp.id
              ) AS sub;
    ```
    |not_in_map|not_in_metric|
    |----------|-------------|
    |0         |7            |

#### 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
```sql
SELECT COUNT(*) AS total_record 
  FROM interest_map;
```
|total_record|
|------------|
|1209        |

#### 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column
* We should left join metric table with map table 

```sql
CREATE TABLE interest_combined AS 
    (
	    SELECT mt.*,
               mp.interest_name, 
               mp.interest_summary, 
               mp.created_at, 
               mp.last_modified
	      FROM interest_metrics AS mt LEFT JOIN interest_map AS mp ON mt.interest_id = mp.id
	);
```
|_month|_year|interest_id|composition|index_value|ranking|percentile_ranking|month_year|interest_name                                       |interest_summary                                                                                                                                                       |created_at         |last_modified      |
|------|-----|-----------|-----------|-----------|-------|------------------|----------|----------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|-------------------|
|7     |2018 |32486      |11.89      |6.19       |1      |99.86             |2018-07-01|Vacation Rental Accommodation Researchers           |People researching and booking rentals accommodations for vacations.                                                                                                   |2018-06-29 12:55:03|2018-06-29 12:55:03|
|7     |2018 |6106       |9.93       |5.31       |2      |99.73             |2018-07-01|Luxury Second Home Owners                           |High income individuals with more than one home.                                                                                                                       |2017-03-27 16:59:29|2018-05-23 11:30:12|
|7     |2018 |18923      |10.85      |5.29       |3      |99.59             |2018-07-01|Online Home Decor Shoppers                          |Consumers shopping online for home decor available for delivery.                                                                                                       |2018-04-19 18:25:02|2018-04-19 18:25:02|
|7     |2018 |6344       |10.32      |5.1        |4      |99.45             |2018-07-01|Hair Care Shoppers                                  |Consumers researching trends and purchasing hair and beauty products.                                                                                                  |2017-05-15 13:04:55|2018-05-31 22:11:37|

* interest_id with the value 21246 has null in `_month`, `_year`, and `month_year` columns, we should be aware of that when analysing
#### 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?


   ```sql
    SELECT COUNT(*) AS total 
	  FROM interest_combined
	 WHERE created_at > month_year;
   ```
   |total|
   |-----|
   |188  |

 * Yes, there are 188 value with this condition. We have to check if `month_year` is really before creation date because we have set the day value to 01 by default
```sql
    SELECT COUNT(*) AS total
      FROM interest_combined
     WHERE DATE_FORMAT(created_at, '%m-%y') > month_year; 
```
|total|
|-----|
|0    |

 * 0 values when we set `created_at` to be in the format of "month-year" only. 
  
### Section B: Interest Analysis 
#### 1. Which interests have been present in all `month_year` dates in our dataset?
* How many unique month_year values are there in the dataset?

  ```sql
  SELECT COUNT(DISTINCT month_year) total_month_year_values
    FROM interest_metrics
   WHERE month_year IS NOT NULL;
  ```
  |total_month_year_values|
  |-----------------------|
  |14                     |

  There are 14 distinct month_year values in the table

* Find the solution
  ```sql
  SELECT mp.interest_name, COUNT(DISTINCT mt.month_year) AS total_month_year_values
    FROM interest_metrics AS mt LEFT JOIN interest_map AS mp ON mt.interest_id = mp.id
   WHERE mt.month_year IS NOT NULL
   GROUP BY mp.interest_name
  HAVING total_month_year_values = 14;
  ```
  |interest_name                                    |total_month_year_values|
  |-------------------------------------------------|-----------------------|
  |Accounting & CPA Continuing Education Researchers|14                     |
  |Affordable Hotel Bookers                         |14                     |
  |Aftermarket Accessories Shoppers|14              |14                       |
  |Alabama Trip Planners|14                          |14                       |
  |Alaskan Cruise Planners|14                                               |
  |Alzheimer and Dementia Researchers|14                                    |
#### 2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the 90% cumulative percentage value?
 
  * How many months in which every interest_id has been presen

    ```sql
    WITH month_year_per_interest AS (
        SELECT DISTINCT interest_id, COUNT(DISTINCT month_year) AS total_month_year
          FROM interest_metrics
         WHERE month_year IS NOT NULL
         GROUP BY 1
    ),
    -- Grouping the first cte by month_year values
    interest_per_month_year AS (
        SELECT totaL_month_year AS month_year, COUNT(interest_id) AS total_interest
          FROM month_year_per_interest
         GROUP BY 1 
    )
    SELECT month_year, total_interest,
           ROUND(SUM(total_interest) OVER (ORDER BY month_year DESC)*100/(SELECT SUM(total_interest) FROM interest_per_month_year), 5) AS cumulative_perc
      FROM interest_per_month_year
     ORDER BY 3 DESC;
    ```
    |month_year|total_interest|cumulative_perc|
    |----------|--------------|---------------|
    |1         |13            |100.0000       |
    |2         |12            |98.9185        |
    |3         |15            |97.9201        |
    |4         |32            |96.6722        |
    |5         |38            |94.0100        |
    |6         |33            |90.8486        |
    |7         |90            |88.1032        |
    |8         |67            |80.6156        |
    |9         |95            |75.0416        |
    |10        |86            |67.1381        |
    |11        |94            |59.9834        |
    |12        |65            |52.1631        |
    |13        |82            |46.7554        |
    |14        |480           |39.9334        |

    months starting from 6 to 1 all have 90 percent or higher
  
#### 3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?

```sql
-- preparing a cte
    WITH cte AS (
        SELECT interest_id, COUNT(DISTINCT month_year) AS total_months
          FROM interest_metrics
         WHERE interest_id IS NOT NULL 
         GROUP BY 1
        HAVING total_months < 6
        )
  SELECT COUNT(interest_id) AS total_interest 
    FROM interest_metrics
   WHERE interest_id IN (SELECT interest_id FROM cte);
```   
|total_interest|
|--------------|
|400           |

400 interest_id values would be removed
  
#### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed `interest` example for your arguments - think about what it means to have less months present from a segment perspective.

  -- I think that it is not true to remove these interests just because they do not have as much month present as other interests, but it is better to take a look at them before making decisions about whether to exclude them or not.
  ```sql
  -- 14 months
  SELECT DISTINCT month_year,
	     COUNT(DISTINCT interest_id) AS total_interest,
         MIN(ranking) AS max_rank
    FROM interest_metrics
   WHERE interest_id IN (
	      SELECT interest_id 
            FROM interest_metrics 
           WHERE month_year IS NOT NULL 
           GROUP BY 1
          HAVING COUNT(DISTINCT month_year) = 14
            ) 
   GROUP BY 1;
 ```
 |month_year|total_interest|max_rank|
 |----------|--------------|--------|
 |2018-07-01|480           |1       |
 |2018-08-01|480           |1       |
 |2018-09-01|480           |1       |
 |2018-10-01|480           |1       |
 |2018-11-01|480           |1       |
 |2018-12-01|480           |3       |
 |2019-01-01|480           |2       |
 |2019-02-01|480           |2       |
 |2019-03-01|480           |2       |
 |2019-04-01|480           |2       |
 |2019-05-01|480           |2       |
 |2019-06-01|480           |2       |
 |2019-07-01|480           |2       |
 |2019-08-01|480           |2       |

 ```sql
  -- 1 month 
  SELECT DISTINCT month_year,
	     COUNT(DISTINCT interest_id) AS total_interest,
         MIN(ranking) AS max_rank
    FROM interest_metrics
   WHERE interest_id IN (
	      SELECT interest_id 
            FROM interest_metrics 
           WHERE month_year IS NOT NULL 
           GROUP BY 1
          HAVING COUNT(DISTINCT month_year) = 1
            )
  ```
  |month_year|total_interest|max_rank|
  |----------|--------------|--------|
  |2018-07-01|6             |283     |
  |2018-08-01|1             |657     |
  |2018-09-01|1             |771     |
  |2019-02-01|2             |1001    |
  |2019-03-01|1             |1135    |
  |2019-08-01|2             |437     |

  We can see that interests present in only 1 month have very low index ranking, which can be misleading in our analysis. We can exclude these values for better analysis

#### 5. After removing these interests - how many unique interests are there for each month?

For the next steps, I will create a new table which will contain only the values we want in our analysis, the `interest` values that only exists in one month will not be in the new table
```sql
CREATE TABLE interest_metrics_new AS (
	SELECT *
      FROM interest_metrics
     WHERE interest_id NOT IN (
		    SELECT interest_id 
              FROM interest_metrics 
             WHERE month_year IS NOT NULL 
             GROUP BY interest_id 
            HAVING COUNT(DISTINCT month_year) < 6 
            )
	);
SELECT month_year, COUNT(DISTINCT interest_id) AS total_interests
  FROM interest_metrics_new
 WHERE month_year IS NOT NULL
 GROUP BY month_year
 ORDER BY 2;
```
|month_year|total_interests|
|----------|---------------|
|2018-07-01|709            |
|2018-08-01|752            |
|2018-09-01|774            |
|2019-06-01|804            |
|2019-05-01|827            |
|2019-07-01|836            |
|2018-10-01|853            |
|2018-11-01|925            |
|2019-01-01|966            |
|2018-12-01|986            |
|2019-04-01|1035           |
|2019-08-01|1062           |
|2019-02-01|1072           |
|2019-03-01|1078           |


### Section C: Segment Analysis

### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? Only use the maximum composition value for each interest but you must keep the corresponding `month_year` 
```sql
  -- Top 10
	  SELECT DISTINCT mn.month_year,
			 mn.interest_id,
			 mp.interest_name,
			 MAX(mn.composition) AS max_composition
	    FROM interest_metrics_new AS mn 
        JOIN interest_map AS mp ON  mn.interest_id = mp.id 
	   GROUP BY month_year, interest_id, interest_name
       ORDER BY 4 DESC
       LIMIT 10;
```
|month_year|interest_id|interest_name                    |max_composition|
|----------|-----------|---------------------------------|---------------|
|2018-12-01|21057      |Work Comes First Travelers       |21.2           |
|2018-10-01|21057      |Work Comes First Travelers       |20.28          |
|2018-11-01|21057      |Work Comes First Travelers       |19.45          |
|2019-01-01|21057      |Work Comes First Travelers       |18.99          |
|2018-07-01|6284       |Gym Equipment Owners             |18.82          |
|2019-02-01|21057      |Work Comes First Travelers       |18.39          |
|2018-09-01|21057      |Work Comes First Travelers       |18.18          |
|2018-07-01|39         |Furniture Shoppers               |17.44          |
|2018-07-01|77         |Luxury Retail Shoppers           |17.19          |
|2018-10-01|12133      |Luxury Boutique Hotel Researchers|15.15          |

```sql
  -- Bottom 10 
	  SELECT DISTINCT mn.month_year,
			 mn.interest_id,
			 mp.interest_name,
			 MAX(mn.composition) AS max_composition
	    FROM interest_metrics_new AS mn 
        JOIN interest_map AS mp ON  mn.interest_id = mp.id 
	   GROUP BY month_year, interest_id, interest_name
       ORDER BY 4
       LIMIT 10;
```
|month_year|interest_id|interest_name                    |max_composition|
|----------|-----------|---------------------------------|---------------|
|2019-05-01|45524      |Mowing Equipment Shoppers        |1.51           |
|2019-05-01|4918       |Gastrointestinal Researchers     |1.52           |
|2019-06-01|35742      |Disney Fans                      |1.52           |
|2019-06-01|34083      |New York Giants Fans             |1.52           |
|2019-04-01|44449      |United Nations Donors            |1.52           |
|2019-05-01|20768      |Beer Aficionados                 |1.52           |
|2019-05-01|39336      |Philadelphia 76ers Fans          |1.52           |
|2019-05-01|6127       |LED Lighting Shoppers            |1.53           |
|2019-05-01|36877      |Crochet Enthusiasts              |1.53           |
|2019-06-01|6314       |Online Directory Searchers       |1.53           |

#### 2. Which 5 interests had the lowest average ranking value?
```sql
SELECT DISTINCT interest_id,
       ROUND(AVG(ranking), 3) AS avg_rnk
  FROM interest_metrics_new
 GROUP BY interest_id
 ORDER BY avg_rnk
 LIMIT 5;
```
|interest_id|avg_rnk|
|-----------|-------|
|41548      |1.000  |
|42203      |4.111  |
|115        |5.929  |
|171        |9.357  |
|4          |11.857 |

#### 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
```SQL
SELECT DISTINCT mn.interest_id,
	   mp.interest_name,
	   ROUND(stddev_samp(mn.percentile_ranking), 2) AS standard_dev
  FROM interest_metrics_new AS mn 
  JOIN interest_map mp ON mn.interest_id = mp.id
 GROUP BY mn.interest_id, mp.interest_name
 ORDER BY 3 DESC
 LIMIT 5;
 ```
|interest_id|interest_name|standard_dev|
|-----------|-------------|------------|
|23         |Techies      |30.18       |
|20764      |Entertainment Industry Decision Makers|28.97       |
|38992      |Oregon Trip Planners|28.32       |
|43546      |Personalized Gift Shoppers|26.24       |
|10839      |Tampa and St Petersburg Trip Planners|25.61       |

#### 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
```sql
 -- Creating a cte for the previous question's values
WITH top_5_std AS (
	SELECT DISTINCT interest_id,
	       ROUND(STDDEV_SAMP(percentile_ranking), 2) AS standard_dev
	  FROM interest_metrics_new
	 GROUP BY interest_id
	 ORDER BY 2 DESC
	 LIMIT 5
),
max_min_perc_rnk AS (
	SELECT	DISTINCT interest_id,
			MAX(percentile_ranking) AS max_perc_rnk,
            MIN(percentile_ranking) AS min_perc_rnk
	  FROM interest_metrics_new
     WHERE interest_id IN (SELECT interest_id FROM top_5_std)
     GROUP BY 1
),
max_month_year AS (
	SELECT	DISTINCT t1.interest_id,
			t1.max_perc_rnk,
			t2.month_year as month_year
	  FROM  max_min_perc_rnk AS t1 
      JOIN  interest_metrics AS t2 On t1.interest_id = t2.interest_id AND t1.max_perc_rnk = t2.percentile_ranking
     WHERE  t2.month_year IS NOT NULL
),
min_month_year AS (
	SELECT	DISTINCT t1.interest_id,
			t1.min_perc_rnk,
			t2.month_year AS month_year
	  FROM  max_min_perc_rnk AS t1 
      JOIN  interest_metrics AS t2 ON t1.interest_id = t2.interest_id AND t1.min_perc_rnk = t2.percentile_ranking
     WHERE  t2.month_year IS NOT NULL
)
SELECT	t1.interest_id,
		mp.interest_name,
		t1.max_perc_rnk,
        t1.month_year,
        t2.min_perc_rnk,
        t2.month_year
  FROM  max_month_year AS t1 
  JOIN  min_month_year AS t2 ON t1.interest_id = t2.interest_id 
  JOIN  interest_map AS mp ON mp.id = t1.interest_id;
```

|interest_id|interest_name|max_perc_rnk|month_year|min_perc_rnk|month_year|
|-----------|-------------|------------|----------|------------|----------|
|23         |Techies      |86.69       |2018-07-01|7.92        |2019-08-01|
|20764      |Entertainment Industry Decision Makers|86.15       |2018-07-01|11.23       |2019-08-01|
|10839      |Tampa and St Petersburg Trip Planners|75.03       |2018-07-01|4.84        |2019-03-01|
|38992      |Oregon Trip Planners|82.44       |2018-11-01|2.2         |2019-07-01|
|43546      |Personalized Gift Shoppers|73.15       |2019-03-01|5.7         |2019-06-01|

#### 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services  should we show to these customers and what should we avoid?

* These customers are interested in travelling, entertainment and technology industries. Their interest in these topics is related to some trends which have to be further explored
* We shuold recommend some products related to these topics via sms and newsletters by inviting them to subscribe.

### Section D: Index Analysis 
The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

### 1. What is the top 10 interests by the average composition for each month?
```sql
WITH cte AS (
	SELECT	mt.interest_id,
			mp.interest_name,
			month_year,
			ROUND(composition/index_value, 2) AS avg_composition,
			RANK() OVER (PARTITION BY month_year ORDER BY ROUN (composition/index_value, 2) DESC) AS rnk
	  FROM  interest_metrics AS mt 
      JOIN  interest_map AS mp ON mt.interest_id = mp.id 
	 WHERE  month_year IS NOT NULL
)
SELECT * 
  FROM cte 
 WHERE rnk <= 10;
```
|interest_id|interest_name|month_year|avg_composition|rnk|
|-----------|-------------|----------|---------------|---|
|6324       |Las Vegas Trip Planners|2018-07-01|7.36           |1  |
|6284       |Gym Equipment Owners|2018-07-01|6.94           |2  |
|4898       |Cosmetics and Beauty Shoppers|2018-07-01|6.78           |3  |
|77         |Luxury Retail Shoppers|2018-07-01|6.61           |4  |
|39         |Furniture Shoppers|2018-07-01|6.51           |5  |
|18619      |Asian Food Enthusiasts|2018-07-01|6.1            |6  |
|6208       |Recently Retired Individuals|2018-07-01|5.72           |7  |
|21060      |Family Adventures Travelers|2018-07-01|4.85           |8  |
|...
### 2. For all of these top 10 interests - which interest appears the most often?
```sql
with cte1 AS (
	SELECT	mt.interest_id,
			mp.interest_name,
			month_year,
			ROUND(composition/index_value, 2) AS avg_composition,
			RANK() OVER (PARTITION BY month_year ORDER BY ROUN (composition/index_value, 2) DESC) AS rnk
	  FROM  interest_metrics AS mt 
      JOIN  interest_map AS mp ON mt.interest_id = mp.id 
	 WHERE  month_year IS NOT NULL
),
cte2 AS (
	SELECT interest_id,
           COUNT(*) AS total_count
	  FROM cte1
	 WHERE rnk <= 10
     GROUP BY interest_id
)
SELECT DISTINCT interest_id, 
       total_count
  FROM cte2
 WHERE total_count = (SELECT MAX(total_count) FROM cte2);
```
|interest_id|avg_rnk|
|-----------|-------|
|41548      |1.000  |
|42203      |4.111  |
|115        |5.929  |
|171        |9.357  |
|4          |11.857 |

### 3. What is the average of the average composition for the top 10 interests for each month?
```sql
WITH cte AS (
	SELECT	mt.interest_id,
			mp.interest_name,
			month_year,
			ROUND(composition/index_value, 2) AS avg_composition,
			RANK() OVER (PARTITION BY month_year ORDER BY ROUND(composition/index_value, 2) DESC) AS rnk
	  FROM interest_metrics AS mt 
      JOIN interest_map AS mp ON mt.interest_id = mp.id 
	 WHERE month_year IS NOT NULL
)
SELECT month_year, 
       ROUND(AVG(avg_composition), 2) AS avg_avg_composition 
  FROM cte
 WHERE rnk <= 10
 GROUP BY month_year;
```
|month_year|avg_avg_composition|
|----------|-------------------|
|2018-07-01|6.04               |
|2018-08-01|5.94               |
|2018-09-01|6.89               |
|2018-10-01|7.07               |
|2018-11-01|6.62               |
|2018-12-01|6.65               |
|2019-01-01|6.32               |
|2019-02-01|6.58               |
|2019-03-01|6.12               |
|2019-04-01|5.75               |
|2019-05-01|3.54               |
|2019-06-01|2.43               |
|2019-07-01|2.76               |
|2019-08-01|2.63               |

### 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below. 
```sql
	-- Create a cte for values with maximum average composition values for each month
	WITH avg_composition_rnk AS (
		SELECT	mt.interest_id,
				mp.interest_name,
				month_year,
				ROUND(composition/index_value, 2) AS avg_composition,
				RANK() OVER (PARTITION BY month_year ORDER BY ROUND(composition/index_value, 2) DESC) AS rnk
		  FROM  interest_metrics AS mt 
          JOIN  interest_map AS mp ON mt.interest_id = mp.id 
		  WHERE month_year IS NOT NULL
	),
    -- create a cte for interests with highest average composition values per month
	top_avg_composition_per_month AS (
		SELECT	DISTINCT month_year,
				interest_id,
				interest_name,
                avg_composition AS max_index_composition
		  FROM avg_composition_rnk
         WHERE rnk = 1 
	)
    SELECT * 
      FROM (
		SELECT	month_year,
				interest_id,
				interest_name,
				max_index_composition,
				ROUND(AVG(max_index_composition) OVER (ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND current ROW), 2) AS 3_month_moving_average,
				CONCAT(LAG(interest_name, 1) OVER (ORDER BY month_year), ": ", LAG(max_index_composition, 1) OVER (ORDER BY month_year)) AS 1_month_ago,
				CONCAT(LAG(interest_name, 2) OVER (ORDER BY month_year), ": ", LAG(max_index_composition, 2) OVER (ORDER BY month_year)) AS 2_month_ago
		  FROM top_avg_composition_per_month
	        ) AS sub 
	 WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01'
	 ORDER BY 1;
```
|month_year|interest_id|interest_name                    |max_index_composition|3_month_moving_average|1_month_ago                      |2_month_ago                      |
|----------|-----------|---------------------------------|---------------------|----------------------|---------------------------------|---------------------------------|
|2018-09-01|21057      |Work Comes First Travelers       |8.26                 |7.61                  |Las Vegas Trip Planners: 7.21    |Las Vegas Trip Planners: 7.36    |
|2018-10-01|21057      |Work Comes First Travelers       |9.14                 |8.2                   |Work Comes First Travelers: 8.26 |Las Vegas Trip Planners: 7.21    |
|2018-11-01|21057      |Work Comes First Travelers       |8.28                 |8.56                  |Work Comes First Travelers: 9.14 |Work Comes First Travelers: 8.26 |
|2018-12-01|21057      |Work Comes First Travelers       |8.31                 |8.58                  |Work Comes First Travelers: 8.28 |Work Comes First Travelers: 9.14 |
|2019-01-01|21057      |Work Comes First Travelers       |7.66                 |8.08                  |Work Comes First Travelers: 8.31 |Work Comes First Travelers: 8.28 |
|2019-02-01|21057      |Work Comes First Travelers       |7.66                 |7.88                  |Work Comes First Travelers: 7.66 |Work Comes First Travelers: 8.31 |
|2019-03-01|7541       |Alabama Trip Planners            |6.54                 |7.29                  |Work Comes First Travelers: 7.66 |Work Comes First Travelers: 7.66 |
|2019-04-01|6065       |Solar Energy Researchers         |6.28                 |6.83                  |Alabama Trip Planners: 6.54      |Work Comes First Travelers: 7.66 |
|2019-05-01|21245      |Readers of Honduran Content      |4.41                 |5.74                  |Solar Energy Researchers: 6.28   |Alabama Trip Planners: 6.54      |
|2019-06-01|6324       |Las Vegas Trip Planners          |2.77                 |4.49                  |Readers of Honduran Content: 4.41|Solar Energy Researchers: 6.28   |
|2019-07-01|6324       |Las Vegas Trip Planners          |2.82                 |3.33                  |Las Vegas Trip Planners: 2.77    |Readers of Honduran Content: 4.41|
|2019-08-01|4898       |Cosmetics and Beauty Shoppers    |2.73                 |2.77                  |Las Vegas Trip Planners: 2.82    |Las Vegas Trip Planners: 2.77    |

-- Section A --
-- 1
    -- First Step
    ALTER TABLE interest_metrics
        DROP COLUMN month_year;
    -- Second step
    ALTER TABLE interest_metrics ADD month_year date;
    -- Third step
    UPDATE interest_metrics
        SET month_year = CAST(CONCAT(_year, '-', 0, _month, '-', 01) AS date)
    WHERE _month != 'NULL' AND _year != 'NULL';
-- 2
 SELECT month_year,
          COUNT(interest_id) AS total_count
   FROM interest_metrics
  GROUP BY month_year
  ORDER BY total_count DESC;
--3 
  SELECT * 
    FROM interest_metrics 
   WHERE month_year IS NULL;

  DELETE 
    FROM interest_metrics
   WHERE interest_id = 'NULL';
--4 
-- First solution
   SELECT (
	    SELECT COUNT(DISTINCT interest_id) 
		  FROM interest_metrics
		 WHERE interest_id NOT IN (SELECT id FROM interest_map)
          ) AS not_in_map,
          (
	    SELECT COUNT(DISTINCT id) 
          FROM interest_map
         WHERE id NOT IN (SELECT interest_id FROM interest_metrics)
          ) AS not_in_metrics;
-- Second solution
   SELECT SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS not_in_map,
	  SUM(CASE WHEN interest_id IS NULL THEN 1 ELSE 0 END) AS not_in_metric
     FROM (
            SELECT * FROM interest_metrics AS mt LEFT JOIN interest_map AS mp ON mt.interest_id = mp.id 
             UNION 
        SELECT * FROM interest_metrics AS mt RIGHT JOIN interest_map AS mp ON mt.interest_id = mp.id
          ) AS sub;
--5 
SELECT COUNT(*) AS total_record 
  FROM interest_map;
--6 
CREATE TABLE interest_combined AS (
	  SELECT mt.*,
             mp.interest_name, 
 		     mp.interest_summary, 
             mp.created_at, 
             mp.last_modified
	      FROM interest_metrics AS mt LEFT JOIN interest_map AS mp ON mt.interest_id = mp.id
	);
--7
SELECT COUNT(*) AS total 
  FROM interest_combined
 WHERE created_at > month_year;

SELECT COUNT(*) AS total
  FROM interest_combined
 WHERE DATE_FORMAT(created_at, '%m-%y') > month_year;

-- Section B 
--1 
  SELECT COUNT(DISTINCT month_year) total_month_year_values
    FROM interest_metrics
   WHERE month_year IS NOT NULL;

  SELECT mp.interest_name, COUNT(DISTINCT mt.month_year) AS total_month_year_values
    FROM interest_metrics AS mt LEFT JOIN interest_map AS mp ON mt.interest_id = mp.id
   WHERE mt.month_year IS NOT NULL
   GROUP BY mp.interest_name
  HAVING total_month_year_values = 14;
--2
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
--3 
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
--4 

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
--5 
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
SELECT month_year, 
       COUNT(DISTINCT interest_id) AS total_interests
  FROM interest_metrics_new
 WHERE month_year IS NOT NULL
 GROUP BY month_year
 ORDER BY 2;

-- Section C 
--1 
   SELECT DISTINCT mn.month_year,
           mn.interest_id,
           mp.interest_name,
  	       MAX(mn.composition) AS max_composition
     FROM interest_metrics_new AS mn 
     JOIN interest_map AS mp ON  mn.interest_id = mp.id 
    GROUP BY month_year, interest_id, interest_name
    ORDER BY 4 DESC
    LIMIT 10;

   SELECT DISTINCT mn.month_year,
			       mn.interest_id,
			       mp.interest_name,
			       MAX(mn.composition) AS max_composition
     FROM interest_metrics_new AS mn 
     JOIN interest_map AS mp ON  mn.interest_id = mp.id 
    GROUP BY month_year, interest_id, interest_name
    ORDER BY 4
    LIMIT 10;
--2
SELECT DISTINCT interest_id,
       ROUND(AVG(ranking), 3) AS avg_rnk
  FROM interest_metrics_new
 GROUP BY interest_id
 ORDER BY avg_rnk
 LIMIT 5;
 --3
 SELECT DISTINCT mn.interest_id,
	     mp.interest_name,
	     ROUND(stddev_samp(mn.percentile_ranking), 2) AS standard_dev
  FROM interest_metrics_new AS mn 
  JOIN interest_map mp ON mn.interest_id = mp.id
 GROUP BY mn.interest_id, mp.interest_name
 ORDER BY 3 DESC
 LIMIT 5;
--4
WITH top_5_std AS (
	SELECT DISTINCT interest_id,
	       ROUND(STDDEV_SAMP(percentile_ranking), 2) AS standard_dev
	  FROM interest_metrics_new
	 GROUP BY interest_id
	 ORDER BY 2 DESC
	 LIMIT 5
),
max_min_perc_rnk AS (
	SELECT DISTINCT interest_id,
		   MAX(percentile_ranking) AS max_perc_rnk,
		   MIN(percentile_ranking) AS min_perc_rnk
     FROM interest_metrics_new
    WHERE interest_id IN (SELECT interest_id FROM top_5_std)
    GROUP BY 1
),
max_month_year AS (
	SELECT DISTINCT t1.interest_id,
           t1.max_perc_rnk,
           t2.month_year as month_year
	  FROM max_min_perc_rnk AS t1 
      JOIN interest_metrics AS t2 On t1.interest_id = t2.interest_id AND t1.max_perc_rnk = t2.percentile_ranking
     WHERE t2.month_year IS NOT NULL
),
min_month_year AS (
	SELECT DISTINCT t1.interest_id,
           t1.min_perc_rnk,
           t2.month_year AS month_year
	  FROM max_min_perc_rnk AS t1 
      JOIN interest_metrics AS t2 ON t1.interest_id = t2.interest_id AND t1.min_perc_rnk = t2.percentile_ranking
     WHERE t2.month_year IS NOT NULL
)
SELECT t1.interest_id,
   	   mp.interest_name,
	   t1.max_perc_rnk,
       t1.month_year,
       t2.min_perc_rnk,
       t2.month_year
  FROM max_month_year AS t1 
  JOIN min_month_year AS t2 ON t1.interest_id = t2.interest_id 
  JOIN interest_map AS mp ON mp.id = t1.interest_id;

-- Section D 
--1
WITH cte AS (
	SELECT mt.interest_id,
		   mp.interest_name,
		   month_year,	
		   ROUND(composition/index_value, 2) AS avg_composition,
		   RANK() OVER (PARTITION BY month_year ORDER BY ROUN (composition/index_value, 2) DESC) AS rnk
	  FROM interest_metrics AS mt 
 	  JOIN interest_map AS mp ON mt.interest_id = mp.id 
	 WHERE month_year IS NOT NULL
)
SELECT * 
  FROM cte 
 WHERE rnk <= 10;
--2
with cte1 AS (
	SELECT mt.interest_id,
		   mp.interest_name,
		   month_year,
		   ROUND(composition/index_value, 2) AS avg_composition,
		   RANK() OVER (PARTITION BY month_year ORDER BY ROUN (composition/index_value, 2) DESC) AS rnk
	  FROM interest_metrics AS mt 
      JOIN interest_map AS mp ON mt.interest_id = mp.id 
	 WHERE month_year IS NOT NULL
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
--3
WITH cte AS (
	SELECT mt.interest_id,
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
--4
	WITH avg_composition_rnk AS (
		 SELECT	mt.interest_id,
                mp.interest_name,
                month_year,
                ROUND(composition/index_value, 2) AS avg_composition,
                RANK() OVER (PARTITION BY month_year ORDER BY ROUND(composition/index_value, 2) DESC) AS rnk
		   FROM interest_metrics AS mt 
		   JOIN interest_map AS mp ON mt.interest_id = mp.id 
		  WHERE month_year IS NOT NULL
	),
    -- create a cte for interests with highest average composition values per month
	top_avg_composition_per_month AS (
		SELECT DISTINCT month_year,
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
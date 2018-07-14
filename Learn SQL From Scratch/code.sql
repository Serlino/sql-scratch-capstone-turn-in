/* Select all columns from the first 10 rows. What columns does the table have? */
SELECT *
FROM survey
LIMIT 10;

/* Query 2: Create the quiz funnel and analyze how many users move from Q1 to Q2, etc. */
 SELECT question, COUNT(user_id) AS 'count'
 FROM survey
 GROUP BY 1;
 
 /* Examine the first five rows of each table in the purchase funnel. What columns does the table have?
 */
SELECT *
FROM quiz
LIMIT 10;

SELECT *
FROM home_try_on
LIMIT 10;

SELECT *
FROM purchase
LIMIT 10;

 /* Create a new table in the requested layout */
WITH funnel AS (
SELECT q.user_id, h.user_id AS 'home_try_on', h.number_of_pairs, p.user_id AS 'purchase'
FROM quiz AS 'q'
	LEFT JOIN home_try_on AS 'h'
		ON q.user_id = h.user_id
	LEFT JOIN purchase AS 'p'
		ON q.user_id = p.user_id
  LIMIT 10
)
SELECT user_id,
CASE
	WHEN funnel.home_try_on IS NULL THEN 'False'
  ELSE 'True'
END AS 'is_home_try_on',
number_of_pairs,
CASE
	WHEN funnel.purchase IS NULL THEN 'False'
  ELSE 'True'
END AS 'is_purchase'
FROM funnel;

/* Calculate the overall conversion rate by aggregating against all rows. */
WITH overall_conversion AS(
WITH funnel AS (
SELECT q.user_id, h.user_id AS 'home_try_on', h.number_of_pairs, p.user_id AS 'purchase'
FROM quiz AS 'q'
	LEFT JOIN home_try_on AS 'h'
		ON q.user_id = h.user_id
	LEFT JOIN purchase AS 'p'
		ON q.user_id = p.user_id
  LIMIT 10
)
SELECT user_id,
CASE
	WHEN funnel.home_try_on IS NULL THEN 'False'
  ELSE 'True'
END AS 'is_home_try_on',
number_of_pairs,
CASE
	WHEN funnel.purchase IS NULL THEN 'False'
  ELSE 'True'
END AS 'is_purchase'
FROM funnel
)
SELECT COUNT(user_id) AS 'total_users',
SUM(CASE
WHEN is_purchase LIKE 'True' THEN 1
ELSE 0
END) AS 'total_purchases', 
ROUND((1.0 * SUM(CASE
WHEN is_purchase LIKE 'True' THEN 1
ELSE 0
END)) / COUNT(user_id), 2)  AS 'overall_conversion_rate'
FROM overall_conversion;

/* Calculate the stepwise conversion rate from quiz to home_try_on and home_try_on to purchase. */

WITH stepwise_conversion AS(
WITH funnel AS (
SELECT q.user_id, h.user_id AS 'home_try_on', h.number_of_pairs, p.user_id AS 'purchase'
FROM quiz AS 'q'
	LEFT JOIN home_try_on AS 'h'
		ON q.user_id = h.user_id
	LEFT JOIN purchase AS 'p'
		ON q.user_id = p.user_id
  LIMIT 10
)
SELECT user_id,
CASE
	WHEN funnel.home_try_on IS NULL THEN 'False'
  ELSE 'True'
END AS 'is_home_try_on',
number_of_pairs,
CASE
	WHEN funnel.purchase IS NULL THEN 'False'
  ELSE 'True'
END AS 'is_purchase'
FROM funnel
)
SELECT COUNT(user_id) AS 'total_users', 
SUM(CASE
WHEN is_home_try_on LIKE 'True' THEN 1
ELSE 0
END) AS 'total_home_trials', 
SUM(CASE
WHEN is_purchase LIKE 'True' THEN 1
ELSE 0
END) AS 'total_purchases', 
ROUND(1.0 * SUM(CASE
WHEN is_home_try_on LIKE 'True' THEN 1
ELSE 0
END), 2) / COUNT(user_id) AS 'conversion_rate_to_home_trial',
ROUND((1.0 * SUM(CASE
WHEN is_purchase LIKE 'True' THEN 1
ELSE 0
END)) / ROUND(1.0 * SUM(CASE
WHEN is_home_try_on LIKE 'True' THEN 1
ELSE 0
END)), 2) AS 'conversion_rate_to_purchase'
FROM stepwise_conversion;
 
 /*Calculate the difference in purchase rates between customers who had 3 number_of_pairs with ones who had 5 number_of_pairs.*/
WITH conversion AS(
WITH funnel_analysis AS(
SELECT 
  q.user_id, 
  h.user_id IS NOT NULL AS 'is_home_try_on',  
  p.user_id IS NOT NULL AS 'is_purchase',
  h.number_of_pairs
FROM quiz AS 'q'
	LEFT JOIN home_try_on AS 'h'
		ON q.user_id = h.user_id
	LEFT JOIN purchase AS 'p'
		ON q.user_id = p.user_id
  LIMIT 10
  )
  SELECT COUNT(user_id) AS 'num_quiz_takers', SUM(is_home_try_on) AS 'num_home_trials', SUM(is_purchase) AS 'num_purchases', number_of_pairs AS 'home_try_on_package'
  FROM funnel_analysis
  GROUP BY 4
ORDER BY 3 DESC
)
SELECT home_try_on_package, SUM(num_home_trials) AS 'home_trials', SUM(num_purchases) AS 'purchases',
ROUND(1.0 * SUM(num_purchases) / SUM(num_home_trials),1) AS 'convertion_rate'
FROM conversion
WHERE home_try_on_package IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC;
              
/* What are the most common results of the style quiz? */
SELECT response, 
	COUNT(response) AS 'num_of_responses'
FROM survey
GROUP BY 1
ORDER BY 2 DESC
LIMIT 50;

/* What are the common types of purchases made? */
SELECT COUNT(product_id) AS 'num_of_sales', product_id
FROM purchase
GROUP BY 2
ORDER BY 1 DESC;
              
SELECT COUNT(style) AS 'style_preference', style
FROM purchase
GROUP BY 2
ORDER BY 1 DESC;
              
SELECT COUNT(color) AS 'color_pref', color
FROM purchase
GROUP BY 2
ORDER BY 1 DESC;

SELECT COUNT(price) AS 'price_pref', price
FROM purchase
GROUP BY 2
ORDER BY 1 DESC;
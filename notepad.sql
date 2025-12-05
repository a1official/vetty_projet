/*question 1
 Approach:
First, remove all refunded transactions by keeping only the rows where refund_time is NULL.
After filtering,group the remaining records by the year and month extracted from purchase_time,
 and then count how many transactions fall into each year–month bucket. */

/* Q1 purchases per month  */
SELECT
  DATE_TRUNC('month', purchase_time) AS month,
  COUNT(*) AS purchases_count
FROM transactions
WHERE refund_time IS NULL
GROUP BY DATE_TRUNC('month', purchase_time)
ORDER BY month;

/*Approach
Directly filter the transactions table to only include purchases made in October 2020.
After applying the date range, group the results by store_id and count how many transactions each store has in that month. 
From that grouped output, keep only the stores with at least five purchases, and finally count how many such stores there are.*/
/* Q2: Stores with at least 5 purchases in October 2020 */
SELECT COUNT(*) AS stores_with_min_5_tx
FROM (
  SELECT store_id, COUNT(*) AS tx_count
  FROM transactions
  WHERE purchase_time >= DATE '2020-10-01'
    AND purchase_time <  DATE '2020-11-01'
  GROUP BY store_id
  HAVING COUNT(*) >= 5
) AS sub;

/* question3 
approach

Focus only on transactions that were actually refunded . 
For each store, calculate how long each refund took by subtracting the purchase timestamp from the refund timestamp. 
Convert that time difference into minutes. Then, for every store, find the smallest refund interval and list those values.
*/

SELECT
  store_id,
  MIN(EXTRACT(EPOCH FROM (refund_time - purchase_time)) / 60.0) AS shortest_refund_minutes
FROM transactions
WHERE refund_time IS NOT NULL
GROUP BY store_id
ORDER BY store_id;


/* Q4 
approach : window function is used
Approach
For each store_id, find the earliest purchase_time and return that row’s gross_transaction_value. We can use ROW_NUMBER() over partition by store_id ordered by purchase_time ASC.
 Q4: gross_transaction_value of each store's first order (including refunds) */
SELECT store_id, purchase_time, gross_transaction_value
FROM (
  SELECT
    store_id,
    purchase_time,
    gross_transaction_value,
    ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time ASC) AS rn
  FROM transactions
) t
WHERE rn = 1
ORDER BY store_id;














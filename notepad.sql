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


/* question 5  approach
Identify each buyer’s very first purchase by ordering their transactions chronologically and assigning a row number starting at 1.
Once we isolate those first-purchase rows, join them to the items table to get the corresponding item names (some may be null if the item doesn’t exist in items). 
Then, count how often each item appears as a buyer’s first purchase. Finally, sort these counts in descending order and return the item that shows up the most.*/
/* Q5: Find the item name most frequently chosen on a buyer's first-ever purchase */
WITH buyer_first_tx AS (
  SELECT
    buyer_id,
    store_id,
    item_id,
    purchase_time,
    ROW_NUMBER() OVER (
      PARTITION BY buyer_id
      ORDER BY purchase_time
    ) AS rn
  FROM transactions
)
SELECT
  it.item_name,
  COUNT(*) AS first_purchase_count
FROM buyer_first_tx b
LEFT JOIN items it
  ON it.store_id = b.store_id
 AND it.item_id  = b.item_id
WHERE b.rn = 1
GROUP BY it.item_name
ORDER BY first_purchase_count DESC
LIMIT 1;   


/*Approach

A transaction is considered refund-processable only if a refund actually happened (i.e., refund_time is not null) and the refund occurred within 72 hours of the original purchase.
To determine this, calculate the time gap between purchase_time and refund_time in hours, then mark the transaction with a flag indicating whether it meets the 72-hour limit.*/
/* Q6: Flag indicating whether refund is processable within 72 hours */
SELECT
    buyer_id,
    store_id,
    item_id,
    purchase_time,
    refund_time,
    CASE
        WHEN refund_time IS NULL THEN 'not_refundable'
        WHEN EXTRACT(EPOCH FROM (refund_time - purchase_time)) / 3600 <= 72
             THEN 'processable'
        ELSE 'not_processable'
    END AS refund_flag
FROM transactions;


/*Approach

Start by filtering out any refunded transactions so that only completed purchases remain.
For each buyer, sort their purchases in chronological order and assign a sequential number using ROW_NUMBER(). 
Once the ranking is applied, select only the entries where the row number equals 2 — these represent each buyer’s second purchase.
*/


WITH cleaned AS (
    SELECT *
    FROM transactions
    WHERE refund_time IS NULL
),
ranked AS (
    SELECT
        buyer_id,
        store_id,
        item_id,
        purchase_time,
        ROW_NUMBER() OVER (
            PARTITION BY buyer_id
            ORDER BY purchase_time
        ) AS rn
    FROM cleaned
)
SELECT *
FROM ranked
WHERE rn = 2;
















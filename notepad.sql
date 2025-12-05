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





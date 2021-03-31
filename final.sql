-- Compute for lift metrics and pvalues for binary metrics 30 day order binary and 30 day view binary using 95% confidence interval
--for orders bin the success rate is similar for both test with 30% success rate. THe pvalue is 0.88 and the imporovement is -1%. 
-- The range of improvement is -14% - 12%


--for item views
--the success rate is very close with 81% on the control and 83% on the treatment. The pvalue is 0.2 meaning that the value might be due to 20% chance
--and therefore not significant
--The lift value is 2.6% with ranging from -1.4% - 6.5%

--2. Reformat the final_assignments_qa to look like the final_assignments table, filling in any missing values with a placeholder of the appropriate data type.

SELECT item_id,
       test_a AS test_assignment,
       'item_test_1' AS test_number,
       '2013-01-05 00:00:00' AS test_start_date
from dsv1069.final_assignments_qa
In [ ]:

--3. Use this table to compute order_binary for the 30 day window after the test_start_date for the test named item_test_2

SELECT test_assignment,
       count(distinct item_id) AS items,
       SUM(order_binary) AS order_binary,
       SUM(order_binary_30d) AS order_binary_30d
FROM
  (SELECT item_test_2_order.item_id,
          item_test_2_order.test_assignment,
         
          max(CASE
                  WHEN when_created > test_start_date then 1
                  ELSE 0
              END) AS order_binary,
          max(CASE
                  WHEN (when_created > test_start_date
                        AND date_part('day', when_created - test_start_date) <= 30) then 1
                  ELSE 0
              END) AS order_binary_30d
   FROM
  (
  SELECT
    final_assignments.*,
    DATE(orders.created_at) AS when_created 
  FROM 
    dsv1069.final_assignments AS final_assignments
  LEFT JOIN
    dsv1069.orders AS orders
  ON
    final_assignments.item_id = orders.item_id
  WHERE
    test_number = 'item_test_2'
  ) AS item_test_2_order
GROUP BY
  item_test_2_order.item_id,
  item_test_2_order.test_assignment

  ) AS order_binary
GROUP BY
  test_assignment


--4. Use this table to compute view_binary for the 30 day window after the test_start_date for the test named item_test_2

SELECT test_assignment,
       test_number,
       count(item) AS item,
       SUM(view_binary) AS view_binary,
       SUM(view_binary_30d) AS view_binary_30d
FROM
  (SELECT final_assignments.item_id as item,
          test_assignment,
          test_number,
          test_start_date,
          max(CASE
                  WHEN date(event_time) > date(test_start_date) then 1
                  ELSE 0
              END) AS view_binary,
          MAX((CASE
                   WHEN date(event_time) - date(test_start_date) BETWEEN 0 AND 30 THEN 1
                   ELSE 0
               END)) AS view_binary_30d
   FROM dsv1069.final_assignments
   LEFT JOIN dsv1069.view_item_events
     ON final_assignments.item_id = view_item_events.item_id
   WHERE test_number = 'item_test_2'
   GROUP BY final_assignments.item_id,
            test_assignment,
            test_number,
            test_start_date) AS view_binary
GROUP BY test_assignment,
         test_number,
         test_start_date


--5 Use the https://thumbtack.github.io/abba/demo/abba.html to compute the lifts in metrics and the p-values for the binary metrics ( 30 day order binary and 30 day view binary) using a interval 95% confidence.

--30 day order binary 
    -- p-value = .74
    -- observed lift = -2.2%
    -- actual lift = -15% - 11%
 
 
 --30 day view binary
    -- p-value = .25
    -- observed lift = 2.3%
    -- actual lift = -1.6% - 6.1%
-- benchmark_queries.sql

\echo '--- BENCHMARKING DEFENSIVE LEFT JOIN ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    c.state,
    SUM(o.order_total) AS total_spend
FROM
    orders o
LEFT JOIN
    customers c ON o.customer_id = c.customer_id
GROUP BY
    c.state;

\echo '--- BENCHMARKING TRUSTING INNER JOIN ---'
\echo 'NOTE: This should be run on the "clean" data for a fair comparison.'
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    c.state,
    SUM(o.order_total) AS total_spend
FROM
    orders o
INNER JOIN
    customers c ON o.customer_id = c.customer_id
GROUP BY
    c.state;
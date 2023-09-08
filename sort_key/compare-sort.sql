SET search_path = automgmt;
select current_schema();
-- Disable result cache to get full query execution time.
set enable_result_cache_for_session='off';

-- Enable psql command execution timing to capture elapsed time.
\timing on
\echo `echo   `
\echo `echo   `
\echo `echo "********************************"`
\echo `echo "****Query1 (Table: sales)****"`
-- Analytical query on sales table with sort keys
SELECT s.saleyear,s.salemonth,e.event_category, sum(s.commission), sum(s.pricepaid)
FROM sales s, events e
WHERE s.saleyear between 2021 and 2022 and s.salemonth=1
AND s.eventid = e.eventid
GROUP BY s.saleyear,s.salemonth,e.event_category
ORDER BY s.saleyear,s.salemonth;
\echo `echo "********************************"`
\echo `echo   `
\echo `echo   `
\echo `echo "********************************"`
\echo `echo "****Query2 (Table: sales_nosort)****"`
-- Analytical query on sales_nosort table without any sort keys
SELECT s.saleyear,s.salemonth,e.event_category, sum(s.commission), sum(s.pricepaid)
FROM sales_nosort s, events e
WHERE s.saleyear between 2021 and 2022 and s.salemonth=1
AND s.eventid = e.eventid
GROUP BY s.saleyear,s.salemonth,e.event_category
ORDER BY s.saleyear,s.salemonth;
\echo `echo "********************************"`

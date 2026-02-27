-- Data Exploration & Grain Checks

-- 1. Candidates
-- Expected Grain: 1 row per candidate_id
SELECT 
    'candidates' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT candidate_id) AS distinct_keys,
    COUNT(*) - COUNT(candidate_id) AS null_keys
FROM candidates;

-- Check for duplicates
SELECT candidate_id, COUNT(*)
FROM candidates
GROUP BY 1
HAVING COUNT(*) > 1;


-- 2. Requisitions
-- Expected Grain: 1 row per req_id
SELECT 
    'requisitions' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT req_id) AS distinct_keys,
    COUNT(*) - COUNT(req_id) AS null_keys
FROM requisitions;

-- Check for duplicates
SELECT req_id, COUNT(*)
FROM requisitions
GROUP BY 1
HAVING COUNT(*) > 1;


-- 3. Applications
-- Expected Grain: 1 row per application_id
-- Note: Data Dictionary might imply intentional duplicates or issues, we should check.
SELECT 
    'applications' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT application_id) AS distinct_keys,
    COUNT(*) - COUNT(application_id) AS null_keys
FROM applications;

-- Check for duplicates (if any exist, they break the grain)
SELECT application_id, COUNT(*)
FROM applications
GROUP BY 1
HAVING COUNT(*) > 1;


-- 4. Stage Events
-- Expected Grain: 1 row per event_id
SELECT 
    'stage_events' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT event_id) AS distinct_keys,
    COUNT(*) - COUNT(event_id) AS null_keys
FROM stage_events;

-- Check intersection of stages
SELECT stage, COUNT(*)
FROM stage_events
GROUP BY 1
ORDER BY 2 DESC;

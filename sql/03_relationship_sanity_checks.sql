-- Relationship & Sanity Checks

-- A. Orphan Checks (Referential Integrity)

-- 1. Applications without Candidates
SELECT COUNT(*) as apps_missing_candidates
FROM applications a
LEFT JOIN candidates c ON a.candidate_id = c.candidate_id
WHERE c.candidate_id IS NULL;

-- 2. Applications without Requisitions
SELECT COUNT(*) as apps_missing_reqs
FROM applications a
LEFT JOIN requisitions r ON a.req_id = r.req_id
WHERE r.req_id IS NULL;

-- 3. Stage Events without Applications
SELECT COUNT(*) as events_missing_apps
FROM stage_events se
LEFT JOIN applications a ON se.application_id = a.application_id
WHERE a.application_id IS NULL;

-- 4. Offers without Applications
SELECT COUNT(*) as offers_missing_apps
FROM offers o
LEFT JOIN applications a ON o.application_id = a.application_id
WHERE a.application_id IS NULL;


-- B. Cardinality Checks

-- 1. Applications per Candidate (1:M)
SELECT candidate_id, COUNT(*) as app_count
FROM applications
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 2. Stage Events per Application (1:M)
SELECT application_id, COUNT(*) as event_count
FROM stage_events
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- C. Row Explosion Tests

-- 1. Candidates -> Applications
-- Should not expand beyond application count
SELECT 
    (SELECT COUNT(*) FROM applications) as expected_rows,
    COUNT(*) as actual_rows
FROM candidates c
JOIN applications a ON c.candidate_id = a.candidate_id;

-- 2. Applications -> Stage Events
-- Should equal stage_events count (unless orphans exist)
SELECT 
    (SELECT COUNT(*) FROM stage_events) as expected_rows,
    COUNT(*) as actual_rows
FROM applications a
JOIN stage_events se ON a.application_id = se.application_id;

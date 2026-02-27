-- Data Quality Test Suite for Trustworthiness

-- 1. Duplicate Application IDs (should be 0)
SELECT application_id, COUNT(*)
FROM applications
GROUP BY 1
HAVING COUNT(*) > 1;

-- 2. Null Critical Foreign Keys (should be 0)
SELECT COUNT(*) as apps_with_null_candidate
FROM applications WHERE candidate_id IS NULL;

SELECT COUNT(*) as apps_with_null_req
FROM applications WHERE req_id IS NULL;

-- 3. Logic: Offer Date BEFORE Onsite Date (should be 0)
-- Corrected: Use MIN(event_ts) for Onsite to avoid false positives if multiple onsites exist
SELECT 
    o.offer_id, 
    o.offered_at, 
    se.onsite_at
FROM offers o
JOIN (
    SELECT application_id, MIN(event_ts) as onsite_at
    FROM stage_events
    WHERE stage = 'Onsite'
    GROUP BY application_id
) se ON o.application_id = se.application_id
WHERE o.offered_at < se.onsite_at;

-- 4. Logic: Hired without Offer (should be 0)
SELECT h.hire_id
FROM hires h
LEFT JOIN offers o ON h.application_id = o.application_id
WHERE o.offer_id IS NULL;

-- 5. Logic: Start Date BEFORE Hire Date (should be 0)
-- Corrected: Compare DATE types explicitly
SELECT hire_id, hired_at, start_date
FROM hires
WHERE start_date < DATE(hired_at);

-- 6. Stage Order Violations (Mock example: Screen after Onsite)
-- Use self-joins on stage_events
SELECT 
    e1.application_id
FROM stage_events e1
JOIN stage_events e2 ON e1.application_id = e2.application_id
WHERE e1.stage = 'Onsite' 
  AND e2.stage = 'Screen'
  AND e1.event_ts < e2.event_ts;

-- 7. Negative Durations in Lifecycle
SELECT 
    a.application_id, 
    a.applied_at, 
    se.event_ts as screen_at
FROM applications a
JOIN stage_events se ON a.application_id = se.application_id
WHERE se.stage = 'Screen'
  AND a.applied_at > se.event_ts;

-- 8. Orphan Stage Events (Missing Application)
-- High value test for referential integrity
SELECT se.application_id
FROM stage_events se
LEFT JOIN applications a ON se.application_id = a.application_id
WHERE a.application_id IS NULL;

-- 9. Null Timestamps or Stages
SELECT COUNT(*) as invalid_events
FROM stage_events 
WHERE event_ts IS NULL OR stage IS NULL;

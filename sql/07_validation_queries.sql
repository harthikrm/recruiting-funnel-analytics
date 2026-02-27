-- Metric Validation & Trust Suite
-- Purpose: Verify reporting layer integrity against raw sources

-- 1. KPI Reconciliation (Raw vs. Reporting)
-- Do we lose any applications in the ETL process?
SELECT 
    (SELECT COUNT(DISTINCT application_id) FROM applications) as raw_count,
    (SELECT COUNT(DISTINCT application_id) FROM application_lifecycle) as reporting_count,
    (SELECT COUNT(DISTINCT application_id) FROM applications) - 
    (SELECT COUNT(DISTINCT application_id) FROM application_lifecycle) as variance;

-- 2. Duplicate Check in Key Tables
-- Reporting layer must be unique by application_id
SELECT 
    application_id, 
    COUNT(*) as dupe_count
FROM application_lifecycle
GROUP BY 1
HAVING COUNT(*) > 1;

-- 3. Stage Completion Ratios (Funnel Logic Check)
-- Screens should not exceed Applications, Hires should not exceed Offers
SELECT 
    SUM(CASE WHEN screen_at IS NOT NULL THEN 1 ELSE 0 END) as screens,
    SUM(CASE WHEN onsite_at IS NOT NULL THEN 1 ELSE 0 END) as onsites,
    SUM(CASE WHEN offered_at IS NOT NULL THEN 1 ELSE 0 END) as offers,
    SUM(CASE WHEN hired_at IS NOT NULL THEN 1 ELSE 0 END) as hires,
    -- Logic Checks
    CASE WHEN SUM(CASE WHEN screen_at IS NOT NULL THEN 1 ELSE 0 END) > COUNT(*) THEN 'FAIL' ELSE 'PASS' END as screen_logic,
    CASE WHEN SUM(CASE WHEN hired_at IS NOT NULL THEN 1 ELSE 0 END) > SUM(CASE WHEN offered_at IS NOT NULL THEN 1 ELSE 0 END) THEN 'FAIL' ELSE 'PASS' END as hire_logic
FROM application_lifecycle;

-- 4. Orphan Event Impact
-- What % of raw events are discarded due to missing parent keys?
SELECT 
    COUNT(*) as total_events,
    SUM(CASE WHEN a.application_id IS NULL THEN 1 ELSE 0 END) as orphan_events,
    (SUM(CASE WHEN a.application_id IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100 as pct_orphans
FROM stage_events se
LEFT JOIN applications a ON se.application_id = a.application_id;

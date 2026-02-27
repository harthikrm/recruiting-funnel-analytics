-- Reporting Layer

-- 1. Application Lifecycle View
-- Pivots stage events to get timestamps for each stage per application
-- Includes deduping logic to handle intentional raw duplicates
CREATE OR REPLACE VIEW application_lifecycle AS
WITH deduped_apps AS (
    SELECT 
        application_id, candidate_id, req_id, applied_at, source, 
        current_status, withdrawn_flag,
        ROW_NUMBER() OVER(PARTITION BY application_id ORDER BY applied_at DESC) as rn
    FROM applications
)
SELECT 
    a.application_id,
    a.candidate_id,
    a.req_id,
    r.role_family,
    r.level,
    r.location,
    r.recruiter_id,
    a.source,
    a.applied_at,
    -- Pivot Stage Events
    MAX(CASE WHEN se.stage = 'Screen' THEN se.event_ts END) as screen_at,
    MAX(CASE WHEN se.stage = 'Phone Interview' THEN se.event_ts END) as phone_at,
    MAX(CASE WHEN se.stage = 'Onsite' THEN se.event_ts END) as onsite_at,
    
    -- Offer Info
    o.offered_at,
    o.offer_status, -- Accepted, Declined, etc.
    
    -- Hire Info
    h.hired_at,
    h.start_date,
    
    CASE 
        WHEN h.hire_id IS NOT NULL THEN 'Hired'
        WHEN o.offer_id IS NOT NULL AND o.offer_status IN ('Declined', 'Rejected') THEN 'Offer Declined'
        WHEN a.withdrawn_flag = 'True' THEN 'Withdrawn'
        ELSE a.current_status
    END as final_status

FROM deduped_apps a
JOIN requisitions r ON a.req_id = r.req_id
LEFT JOIN stage_events se ON a.application_id = se.application_id
LEFT JOIN offers o ON a.application_id = o.application_id
LEFT JOIN hires h ON a.application_id = h.application_id
WHERE a.rn = 1 -- Keep only the latest version of each application_id
GROUP BY 
    a.application_id, a.candidate_id, a.req_id, r.role_family, r.level, r.location, r.recruiter_id,
    a.source, a.applied_at, o.offered_at, o.offer_status, h.hired_at, h.start_date,
    a.withdrawn_flag, a.current_status, h.hire_id, o.offer_id;


-- 2. Weekly Recruiting KPIs Table
-- Aggregated metrics by Week, Role, and Location
DROP TABLE IF EXISTS recruiting_kpis_weekly;
CREATE TABLE recruiting_kpis_weekly AS
SELECT 
    DATE_FORMAT(applied_at, '%Y-%u') as report_week,
    role_family,
    location,
    COUNT(DISTINCT application_id) as apps_count,
    COUNT(DISTINCT CASE WHEN screen_at IS NOT NULL THEN application_id END) as screens_count,
    COUNT(DISTINCT CASE WHEN onsite_at IS NOT NULL THEN application_id END) as onsites_count,
    COUNT(DISTINCT CASE WHEN offered_at IS NOT NULL THEN application_id END) as offers_count,
    COUNT(DISTINCT CASE WHEN hired_at IS NOT NULL THEN application_id END) as hires_count,
    
    -- Conversion Rates (Safe Divide)
    COUNT(DISTINCT CASE WHEN screen_at IS NOT NULL THEN application_id END) * 1.0 / NULLIF(COUNT(DISTINCT application_id), 0) as app_to_screen_rate,
    COUNT(DISTINCT CASE WHEN onsite_at IS NOT NULL THEN application_id END) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN screen_at IS NOT NULL THEN application_id END), 0) as screen_to_onsite_rate,
    COUNT(DISTINCT CASE WHEN offered_at IS NOT NULL THEN application_id END) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN onsite_at IS NOT NULL THEN application_id END), 0) as onsite_to_offer_rate,
    COUNT(DISTINCT CASE WHEN hired_at IS NOT NULL THEN application_id END) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN offered_at IS NOT NULL THEN application_id END), 0) as offer_accept_rate,

    -- Time Metrics (Generic AVG handling NULLs safely by default, but explicit CASE allows cleaner logic control)
    AVG(CASE WHEN offered_at IS NOT NULL THEN DATEDIFF(offered_at, applied_at) END) as avg_days_to_offer,
    AVG(CASE WHEN hired_at IS NOT NULL THEN DATEDIFF(hired_at, applied_at) END) as avg_days_to_hire

FROM application_lifecycle
GROUP BY 
    DATE_FORMAT(applied_at, '%Y-%u'),
    role_family,
    location;

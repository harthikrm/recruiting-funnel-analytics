-- Analysis Queries (Insights)

-- 1. Biggest Funnel Drop-off (Global)
SELECT 
    COUNT(application_id) as apps,
    COUNT(screen_at) as screens,
    COUNT(onsite_at) as onsites,
    COUNT(offered_at) as offers,
    COUNT(hired_at) as hires,
    (COUNT(screen_at)/COUNT(application_id)) * 100 as app_to_screen_pct,
    (COUNT(onsite_at)/COUNT(screen_at)) * 100 as screen_to_onsite_pct,
    (COUNT(offered_at)/COUNT(onsite_at)) * 100 as onsite_to_offer_pct,
    (COUNT(hired_at)/COUNT(offered_at)) * 100 as offer_to_hire_pct
FROM application_lifecycle;

-- 2. Source Performance (Conversion to Hire)
SELECT 
    source,
    COUNT(application_id) as total_apps,
    COUNT(hired_at) as total_hires,
    (COUNT(hired_at)/COUNT(application_id)) * 100 as hire_rate_pct
FROM application_lifecycle
GROUP BY 1
ORDER BY 4 DESC;

-- 3. Time-to-Hire by Role Family
SELECT 
    role_family,
    AVG(DATEDIFF(hired_at, applied_at)) as avg_days_to_hire,
    MIN(DATEDIFF(hired_at, applied_at)) as min_days,
    MAX(DATEDIFF(hired_at, applied_at)) as max_days
FROM application_lifecycle
WHERE hired_at IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 4. Offer Acceptance Rate by Location
SELECT 
    location,
    COUNT(offered_at) as offers_extended,
    COUNT(hired_at) as offers_accepted,
    (COUNT(hired_at)/COUNT(offered_at)) * 100 as acceptance_rate
FROM application_lifecycle
WHERE offered_at IS NOT NULL
GROUP BY 1
ORDER BY 4 ASC;

-- 5. Drop-off Diagnostics: Where do we lose the most candidates?
-- (Breakdown by stage status if available, or just funnel math)
SELECT 
    final_status,
    COUNT(*) as count,
    (COUNT(*) / (SELECT COUNT(*) FROM application_lifecycle)) * 100 as pct_of_total
FROM application_lifecycle
GROUP BY 1
ORDER BY 2 DESC;

-- 6. Offer Acceptance Rate by Comp Band (Advanced)
-- Impact: Are we losing candidates because we simply aren't paying enough?
SELECT 
    o.comp_band,
    COUNT(al.offered_at) as offers_extended,
    COUNT(al.hired_at) as offers_accepted,
    CONCAT(ROUND((COUNT(al.hired_at) * 1.0 / COUNT(al.offered_at)) * 100, 1), '%') as acceptance_rate
FROM application_lifecycle al
JOIN offers o ON al.application_id = o.application_id
WHERE al.offered_at IS NOT NULL
GROUP BY 1
ORDER BY 1 ASC;

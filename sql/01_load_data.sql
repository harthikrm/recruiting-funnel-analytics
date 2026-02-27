/* 
NOTE:
This file contains template LOAD DATA statements.
Due to MySQL secure-file restrictions on local machines,
CSV imports were performed using MySQL Workbench Import Wizard.
*/

USE RecruitingAnalyticsDB;

SET GLOBAL local_infile = 1;

-- Load Candidates
LOAD DATA LOCAL INFILE '/Users/harthikmallichetty/Desktop/recruiting-funnel-analytics/data/raw/candidates.csv'
INTO TABLE candidates
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load Requisitions (handled closed_at NULLs)
LOAD DATA LOCAL INFILE '/Users/harthikmallichetty/Desktop/recruiting-funnel-analytics/data/raw/requisitions.csv'
INTO TABLE requisitions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(req_id, opened_at, @closed_at, department, role_family, level, location, priority, recruiter_id, hiring_manager_id, headcount)
SET closed_at = NULLIF(@closed_at, '');

-- Load Applications
LOAD DATA LOCAL INFILE '/Users/harthikmallichetty/Desktop/recruiting-funnel-analytics/data/raw/applications.csv'
INTO TABLE applications
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load Stage Events
LOAD DATA LOCAL INFILE '/Users/harthikmallichetty/Desktop/recruiting-funnel-analytics/data/raw/stage_events.csv'
INTO TABLE stage_events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(event_id, application_id, stage, @event_ts)
SET event_ts = STR_TO_DATE(@event_ts, '%Y-%m-%dT%H:%i:%s');

-- Load Offers
LOAD DATA LOCAL INFILE '/Users/harthikmallichetty/Desktop/recruiting-funnel-analytics/data/raw/offers.csv'
INTO TABLE offers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(offer_id, application_id, candidate_id, req_id, @offered_at, offer_status, comp_band)
SET offered_at = STR_TO_DATE(@offered_at, '%Y-%m-%dT%H:%i:%s');

-- Load Hires
LOAD DATA LOCAL INFILE '/Users/harthikmallichetty/Desktop/recruiting-funnel-analytics/data/raw/hires.csv'
INTO TABLE hires
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(hire_id, application_id, candidate_id, req_id, @hired_at, start_date)
SET hired_at = STR_TO_DATE(@hired_at, '%Y-%m-%dT%H:%i:%s');

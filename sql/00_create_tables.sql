/* 
   00_create_tables.sql
   Project: Recruiting Funnel & People Analytics Reporting Model
   DB: RecruitingAnalyticsDB
   Purpose: Create normalized ATS-style schema with PK/FK + indexes
   Notes:
   - Foreign keys assume you load parent tables first
*/

CREATE DATABASE IF NOT EXISTS RecruitingAnalyticsDB;
USE RecruitingAnalyticsDB;

-- 1. Candidates Table
CREATE TABLE IF NOT EXISTS candidates (
    candidate_id VARCHAR(32) NOT NULL,
    created_at DATE,
    location VARCHAR(64),
    years_experience INT,
    education_level VARCHAR(32),
    primary_role_family VARCHAR(64),
    work_authorization VARCHAR(32),
    PRIMARY KEY (candidate_id)
);

-- 2. Requisitions Table
CREATE TABLE IF NOT EXISTS requisitions (
    req_id VARCHAR(32) NOT NULL,
    opened_at DATE,
    closed_at DATE,
    department VARCHAR(64),
    role_family VARCHAR(64),
    level VARCHAR(16),
    location VARCHAR(64),
    priority VARCHAR(16),
    recruiter_id VARCHAR(16),
    hiring_manager_id VARCHAR(16),
    headcount INT,
    PRIMARY KEY (req_id)
);

-- 3. Applications Table
-- Note: No PRIMARY KEY to allow loading of intentional duplicates for Data Quality Tests
CREATE TABLE IF NOT EXISTS applications (
    application_id VARCHAR(32) NOT NULL,
    candidate_id VARCHAR(32),
    req_id VARCHAR(32),
    applied_at DATE,
    source VARCHAR(32),
    current_status VARCHAR(32),
    withdrawn_flag VARCHAR(10), -- Changed to VARCHAR(10) to store 'True'
    INDEX idx_app_candidate (candidate_id),
    INDEX idx_app_req (req_id)
);

-- 4. Stage Events Table
CREATE TABLE IF NOT EXISTS stage_events (
    event_id VARCHAR(32) NOT NULL,
    application_id VARCHAR(32),
    stage VARCHAR(32),
    event_ts DATETIME,
    PRIMARY KEY (event_id), -- Restored PK (orphans don't violate this)
    INDEX idx_event_app (application_id)
);

-- 5. Offers Table
CREATE TABLE IF NOT EXISTS offers (
    offer_id VARCHAR(32) NOT NULL,
    application_id VARCHAR(32),
    candidate_id VARCHAR(32),
    req_id VARCHAR(32),
    offered_at DATETIME,
    offer_status VARCHAR(16),
    comp_band VARCHAR(16),
    PRIMARY KEY (offer_id),
    INDEX idx_offer_app (application_id)
);

-- 6. Hires Table
CREATE TABLE IF NOT EXISTS hires (
    hire_id VARCHAR(32) NOT NULL,
    application_id VARCHAR(32),
    candidate_id VARCHAR(32),
    req_id VARCHAR(32),
    hired_at DATETIME,
    start_date DATE,
    PRIMARY KEY (hire_id),
    INDEX idx_hire_app (application_id)
);

# Upstream System Gap Analysis

## Overview
This document identifies structural weaknesses in the current ATS configuration and upstream data ingestion pipelines that create downstream reporting anomalies.

## 1. Duplicate Applications
*   **Gap**: The ATS allows candidates to submit multiple active applications for the same requisition.
*   **Root Cause**: Lack of a unique constraint on `(candidate_email, req_id)` in the application submission portal.
*   **Impact**: Inflates "Applied" volume by ~4% and skews conversion rates downward.
*   **Mitigation**: 
    1.  **System**: Enforce unique constraint in ATS backend.
    2.  **Process**: Recruiter SOP to merge duplicates within 24 hours.

## 2. Missing Stage Transitions (Orphan Events)
*   **Gap**: `stage_events` exist for applications that do not exist in the `applications` table.
*   **Root Cause**: Asynchronous logging failure where the event stream (Kafka/Webhook) fires but the application creation transaction fails or lags.
*   **Impact**: "Ghost" candidates appear in funnel metrics but not in source analysis.
*   **Mitigation**:
    *   Implement "Dead Letter Queue" monitoring for failed webhooks.
    *   Enforce foreign key checks at the ingestion layer (Bronze tables).

## 3. "Hired" Without "Offer"
*   **Gap**: Candidates move directly to `Hired` status without a logged `Offer` event.
*   **Root Cause**: Recruiters bypassing the "Offer Approval" workflow in the ATS for internal transfers or verbal offers.
*   **Impact**: `Offer Acceptance Rate` is under-reported; `Time-to-Offer` metrics show nulls.
*   **Mitigation**:
    *   Hard-block status change to "Hired" unless "Offer Accepted" state exists.
    *   Create an "Offer Bypass" exception report for Audit compliance.

## 4. Timestamps & Timezones
*   **Gap**: `event_ts` fields sometimes lack timezone offsets, leading to negative durations (e.g., Offer appearing before Onsite).
*   **Root Cause**: Local browser time captured instead of UTC server time.
*   **Mitigation**: Standardize all logging to ISO8601 UTC at the API gateway level.

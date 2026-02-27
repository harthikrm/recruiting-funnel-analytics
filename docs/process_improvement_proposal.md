# Process Improvement Proposal: Hiring Velocity & Data Integrity

## Executive Summary
Current ATS configuration gaps allow 4% duplicate applications and 12% "Orphan" events, creating mistrust in funnel metrics. This proposal outlines 4 technical and process changes to improve data fidelity and hiring velocity visibility.

## 1. Upstream Data Controls (ATS Configuration)
*   **Problem**: Candidates can apply to the same Role ID multiple times.
*   **Proposal**: Enable "Unique Constraint" on `(Candidate Email + Requisition ID)` in the application portal.
*   **Impact**: Eliminates manual de-duplication work for coordinators (~5 hrs/week).

## 2. Enforce Stage Transitions
*   **Problem**: Recruiters skip steps (e.g., move directly to "Offer") causing NULL timestamps for "Screen" or "Onsite".
*   **Proposal**: Configure ATS "Mandatory Workflow" rules where skipping a stage automatically backfills the timestamp or requires a waiver code.
*   **Impact**: 100% accurate "Time in Stage" reporting for bottleneck analysis.

## 3. Hiring Manager Service Level Agreements (SLA)
*   **Problem**: "Resume Review" stage averages 14 days with high variance.
*   **Proposal**: Implement an automated Slack alert to Hiring Managers when candidate sits in "Review" > 48 hours.
*   **Impact**: Target reduction of Time-to-Hire by 15%.

## 4. "Offer Approval" Integration
*   **Problem**: Offers are sometimes strictly verbal, leading to "Hired without Offer" records.
*   **Proposal**: Integrate Docusign/Offer Letter generation directly into the ATS "Offer" stage.
*   **Impact**: Ensures `offered_at` timestamp is captured systematically, enabling accurate Offer Acceptance Rate (OAR) tracking.

# Data Quality Testing Framework

This document outlines the automated Pytest suite implemented in `tests/data_quality_tests.py` to ensure the integrity and reliability of our processed reporting data (`application_lifecycle.csv` and `recruiting_kpis_weekly.csv`).

## Automated Tests

### 1. Unique Applications
- **Function**: `test_no_duplicate_applications`
- **Purpose**: Ensures there are no duplicated funnel entries in the processed dataset so counts remain accurate.
- **Validation**: Checks that the `application_id` column contains strictly unique values.

### 2. Candidate Referential Integrity
- **Function**: `test_no_null_candidates`
- **Purpose**: Validates structural completeness for candidate tracking.
- **Validation**: Asserts that every application record maps to a valid, non-null `candidate_id`.

### 3. Chronological Stage Progression
- **Function**: `test_valid_stage_order`
- **Purpose**: Validates the time-series logic of candidates moving through the funnel.
- **Validation**: Ensures that candidates who reached the screening stage have a `screen_at` timestamp that is greater than or equal to their `applied_at` timestamp.

### 4. Valid Time-to-Hire Duration
- **Function**: `test_no_negative_duration`
- **Purpose**: Prevents logical anomalies resulting in negative lifecycle durations (i.e., being hired before applying).
- **Validation**: Asserts that the computed duration between `hired_at` and `applied_at` is greater than or equal to 0 days for all hired candidates.

### 5. Offer Acceptance Rate Boundaries
- **Function**: `test_offer_acceptance_rate`
- **Purpose**: Verifies that aggregated percentage metrics are contained within mathematically valid bounds.
- **Validation**: Confirms that every pre-calculated Weekly Offer Acceptance Rate falls strictly between 0 and 1 (0% to 100%).

## Running the Suite

The tests expect `application_lifecycle.csv` and `recruiting_kpis_weekly.csv` to exist in the `data/processed/` directory. Simply run the following command from the project root:

```bash
pytest tests/data_quality_tests.py
```

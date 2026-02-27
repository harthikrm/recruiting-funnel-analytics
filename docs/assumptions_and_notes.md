# Assumptions & Notes

## Data Grain & Keys
| Table | Primary Key | Grain | Notes |
|-------|-------------|-------|-------|
| `candidates` | `candidate_id` | 1 row per unique candidate | Candidates can have multiple applications. |
| `requisitions` | `req_id` | 1 row per job opening | Headcount might be >1, but req_id is unique. |
| `applications` | `application_id` | 1 row per application | Connects Candidate <-> Requisition. |
| `stage_events` | `event_id` | 1 row per status change | Multiple rows per application. |
| `offers` | `offer_id` | 1 row per offer extended | Usually 1 per app, but could be re-issued (we assume last valid). |
| `hires` | `hire_id` | 1 row per hire | Final success state. |

## Join Rules
1. **Always Left Join to Dimension Tables**: When starting from `applications`, left join to `candidates` and `requisitions`.
2. **Pivot Stage Events**: Do NEVER join `stage_events` directly for aggregation unless checking specific event logic. Use `application_lifecycle` view where events are pivoted to 1 row per app.
3. **Offer Logic**: We assume the latest offer is the valid one if multiple exist (though dataset seems to have 1:1).

## Data Quality Checks
- **Duplicates**: Raw tables intentionally do *not* enforce Primary Key constraints. This allows `sql/04_data_quality_tests.sql` to detect and report on duplicate records (e.g., the 12 intentional duplicate applications).
- **Orphans**: We flag applications without candidates/reqs, but in reporting we may either `INNER JOIN` (exclude them) or `LEFT JOIN` (keep them with NULLs) depending on strictness.
    - *Decision*: `application_lifecycle` uses `LEFT JOIN` to preserve application counts even if metadata is missing.
- **Logic**: We test for "Hired without Offer" and "Offer before Onsite". These are flagged in `sql/04_data_quality_tests.sql`.

## Known Limitations
- **Time Zones**: All timestamps assumed UTC.
- **Currency**: `comp_band` is categorical, not numeric salary.
- **Status History**: `current_status` in `applications` table might lag behind `stage_events` if not updated in real-time (in a real ATS). We trust `stage_events` for funnel timing.

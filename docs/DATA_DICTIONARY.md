# Synthetic Recruiting Funnel Dataset (ATS-style)

Generated synthetic data to support a Recruiting Funnel & People Analytics reporting project.

## Files
- **candidates.csv**: 1 row per candidate
- **requisitions.csv**: 1 row per job requisition
- **applications.csv**: 1 row per application (plus 12 intentional duplicate rows for data-quality tests)
- **stage_events.csv**: 1 row per stage event per application (includes 5 intentional orphan events and 2 out-of-order offer events)
- **offers.csv**: 1 row per offer (derived from stage_events)
- **hires.csv**: 1 row per hire (derived from stage_events)

## Relationships
- candidates 1:M applications  
- requisitions 1:M applications  
- applications 1:M stage_events  
- applications 0/1 offers  
- applications 0/1 hires  

## Pipeline
Applied → Screen → Phone Interview → Onsite → Offer → Hired/Rejected/Withdrawn

## Intentional data-quality cases (for SQL tests)
- Duplicate application rows: 12
- Orphan stage events (missing application): 5
- Out-of-order offer events (offer before onsite): 2

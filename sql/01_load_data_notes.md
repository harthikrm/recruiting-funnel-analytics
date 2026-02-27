# Data Loading Notes

## Method
Used `LOAD DATA LOCAL INFILE` for reproducibility and speed.
See `sql/01_load_data.sql` for the exact script.

## Expected Row Counts (from raw files)
- **candidates**: $(wc -l data/raw/candidates.csv | awk '{print $1-1}')
- **requisitions**: $(wc -l data/raw/requisitions.csv | awk '{print $1-1}')
- **applications**: $(wc -l data/raw/applications.csv | awk '{print $1-1}')
- **stage_events**: $(wc -l data/raw/stage_events.csv | awk '{print $1-1}')
- **offers**: $(wc -l data/raw/offers.csv | awk '{print $1-1}')
- **hires**: $(wc -l data/raw/hires.csv | awk '{print $1-1}')

## Validation Queries
After running the load script, execute:
```sql
SELECT 'candidates' as table_name, COUNT(*) as count FROM candidates
UNION ALL
SELECT 'requisitions', COUNT(*) FROM requisitions
UNION ALL
SELECT 'applications', COUNT(*) FROM applications
UNION ALL
SELECT 'stage_events', COUNT(*) FROM stage_events
UNION ALL
SELECT 'offers', COUNT(*) FROM offers
UNION ALL
SELECT 'hires', COUNT(*) FROM hires;
```

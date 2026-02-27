# KPI Definitions

## Volume Metrics
- **Applications**: Count of unique `application_id`s submitted within the period.
- **Screens**: Count of applications that reached the 'Screen' stage.
- **Onsites**: Count of applications that reached the 'Onsite' stage.
- **Offers**: Count of applications that received an Offer (recorded in `offers` table).
- **Hires**: Count of applications that resulted in a Hire (recorded in `hires` table).

## Conversion Rates
- **App to Screen %**: `Screens / Applications`
- **Screen to Onsite %**: `Onsites / Screens`
- **Onsite to Offer %**: `Offers / Onsites`
- **Offer Acceptance Rate (OAR)**: `Hires / Offers` (Percentage of extended offers that were accepted)

## Velocity Metrics (Time-to-X)
- **Time to Offer (Days)**: `Date(Offered At) - Date(Applied At)`
    - *Calculation*: Average or Median days for applications that received an offer.
- **Time to Hire (Days)**: `Date(Hired At) - Date(Applied At)`
    - *Calculation*: Average or Median days for applications that were hired.

## Dimensions
- **Source**: Where the candidate applied from (LinkedIn, Indeed, Referral, etc.).
- **Role Family**: The functional area of the job (Engineering, Sales, etc.).
- **Location**: Office location (Austin, TX, etc.).
- **Recruiter**: The primary recruiter assigned to the Requisition.

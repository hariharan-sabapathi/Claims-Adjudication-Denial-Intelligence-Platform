-- Staging pass-through over the Fact_Claims_Adjudication table loaded by the
-- PySpark job (ingest_claims.py). Kept as a thin view so marts never
-- reference the raw-loaded table name directly.

select
    claim_id,
    patient_id,
    provider_id,
    diagnosis_code,
    carc_code,
    claim_type,
    clm_from_dt,
    clm_thru_dt,
    billed_paid_amt,
    primary_pyr_pd_amt,
    adjudication_status,
    days_since_submission,
    ar_aging_bucket
from {{ source('claims_raw', 'fact_claims_adjudication') }}

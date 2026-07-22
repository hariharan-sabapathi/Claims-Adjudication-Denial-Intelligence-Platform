-- Header KPI cards for the Power BI Denial Control Tower.
-- "Expected revenue" for a denied claim is proxied by the average paid
-- amount for first-pass-paid claims of the same claim type, since a denied
-- claim's billed_paid_amt is $0 by construction in this source data.

with avg_paid as (
    select
        claim_type,
        avg(billed_paid_amt) as avg_paid_amt
    from {{ ref('stg_fact_claims_adjudication') }}
    where adjudication_status = 'Paid - First Pass'
    group by claim_type
),

enriched as (
    select
        f.*,
        case when f.adjudication_status = 'Denied' then a.avg_paid_amt else f.billed_paid_amt end as expected_amt
    from {{ ref('stg_fact_claims_adjudication') }} f
    join avg_paid a on f.claim_type = a.claim_type
)

select
    sum(expected_amt) as total_expected_revenue,
    sum(billed_paid_amt) * 100.0 / nullif(sum(expected_amt), 0) as net_collection_ratio_pct,
    count(*) filter (where adjudication_status = 'Paid - First Pass') * 100.0 / count(*) as clean_claim_rate_pct,
    sum(expected_amt) filter (where adjudication_status = 'Denied' and ar_aging_bucket = '90+') as overdue_ar_90plus
from enriched

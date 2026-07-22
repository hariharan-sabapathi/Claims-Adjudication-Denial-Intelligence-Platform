-- Provider x Aging Bucket matrix for the Power BI heatmap. See
-- kpi_header_cards.sql for why denied-claim $ amounts are proxied via
-- avg paid amount rather than read off billed_paid_amt (which is $0 for
-- denied claims by construction).

with avg_paid as (
    select claim_type, avg(billed_paid_amt) as avg_paid_amt
    from {{ ref('stg_fact_claims_adjudication') }}
    where adjudication_status = 'Paid - First Pass'
    group by claim_type
)

select
    f.provider_id,
    f.ar_aging_bucket,
    count(*) as claim_count,
    round(sum(a.avg_paid_amt), 2) as at_risk_amt_proxy
from {{ ref('stg_fact_claims_adjudication') }} f
join avg_paid a on f.claim_type = a.claim_type
where f.adjudication_status = 'Denied'
group by f.provider_id, f.ar_aging_bucket

select
    provider_id,
    count(*) as total_claims,
    count(*) filter (where adjudication_status = 'Paid - First Pass') * 100.0 / count(*) as clean_claim_rate_pct
from {{ ref('stg_fact_claims_adjudication') }}
group by provider_id
having count(*) >= 5
order by clean_claim_rate_pct asc

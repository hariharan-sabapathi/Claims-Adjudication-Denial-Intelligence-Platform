select
    f.carc_code,
    c.description,
    c.preventability_bucket,
    count(*) as denial_count,
    round(
        count(*) * (
            select avg(billed_paid_amt)
            from {{ ref('stg_fact_claims_adjudication') }}
            where adjudication_status = 'Paid - First Pass'
        ), 2
    ) as estimated_financial_loss
from {{ ref('stg_fact_claims_adjudication') }} f
join {{ source('claims_raw', 'dim_carc_denials') }} c on f.carc_code = c.carc_code
where f.adjudication_status = 'Denied'
group by f.carc_code, c.description, c.preventability_bucket
order by estimated_financial_loss desc

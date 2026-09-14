with all_dates as (

    select to_date(pushed_at) as date_day
    from {{ ref('commits') }}

    union all

    select to_date(opened_at) as date_day
    from {{ ref('pull_requests') }}

    union all

    select to_date(merged_at) as date_day
    from {{ ref('pull_requests') }}

    union all

    select to_date(closed_at) as date_day
    from {{ ref('pull_requests') }}

    union all

    select to_date(opened_at) as date_day
    from {{ ref('issues') }}

    union all

    select to_date(closed_at) as date_day
    from {{ ref('issues') }}

),

date_bounds as (

    select
        min(date_day) as min_date,
        max(date_day) as max_date
    from all_dates
    where date_day is not null

),

calendar as (

    select
        explode(
            sequence(
                min_date,
                max_date,
                interval 1 day
            )
        ) as date_day
    from date_bounds

)

select
    cast(date_format(date_day, 'yyyyMMdd') as int) as date_id,
    date_day,

    dayofweek(date_day) as day_of_week,

    case
        when dayofweek(date_day) in (1, 7) then true
        else false
    end as is_weekend,

    weekofyear(date_day) as iso_week,

    year(date_day) as year

from calendar

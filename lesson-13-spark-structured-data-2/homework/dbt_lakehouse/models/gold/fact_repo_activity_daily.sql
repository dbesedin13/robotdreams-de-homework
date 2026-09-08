with commit_daily as (

    select
        md5(repo_name) as repo_id,

        cast(
            date_format(pushed_at, 'yyyyMMdd')
            as int
        ) as date_id,

        count(*) as commits,
        count(distinct pushed_by) as distinct_committers,
        cast(0 as bigint) as prs_opened,
        cast(0 as bigint) as prs_merged,
        cast(0 as bigint) as issues_opened,
        cast(0 as bigint) as issues_closed,
        cast(0 as bigint) as stars,
        cast(0 as bigint) as forks

    from {{ ref('commits') }}

    group by
        repo_name,
        date_format(pushed_at, 'yyyyMMdd')

),

pr_opened_daily as (

    select
        md5(repo_name) as repo_id,

        cast(
            date_format(opened_at, 'yyyyMMdd')
            as int
        ) as date_id,

        cast(0 as bigint) as commits,
        cast(0 as bigint) as distinct_committers,
        count(*) as prs_opened,
        cast(0 as bigint) as prs_merged,
        cast(0 as bigint) as issues_opened,
        cast(0 as bigint) as issues_closed,
        cast(0 as bigint) as stars,
        cast(0 as bigint) as forks

    from {{ ref('pull_requests') }}

    where opened_at is not null

    group by
        repo_name,
        date_format(opened_at, 'yyyyMMdd')

),

pr_merged_daily as (

    select
        md5(repo_name) as repo_id,

        cast(
            date_format(merged_at, 'yyyyMMdd')
            as int
        ) as date_id,

        cast(0 as bigint) as commits,
        cast(0 as bigint) as distinct_committers,
        cast(0 as bigint) as prs_opened,
        count(*) as prs_merged,
        cast(0 as bigint) as issues_opened,
        cast(0 as bigint) as issues_closed,
        cast(0 as bigint) as stars,
        cast(0 as bigint) as forks

    from {{ ref('pull_requests') }}

    where merged_at is not null

    group by
        repo_name,
        date_format(merged_at, 'yyyyMMdd')

),

issue_opened_daily as (

    select
        md5(repo_name) as repo_id,

        cast(
            date_format(opened_at, 'yyyyMMdd')
            as int
        ) as date_id,

        cast(0 as bigint) as commits,
        cast(0 as bigint) as distinct_committers,
        cast(0 as bigint) as prs_opened,
        cast(0 as bigint) as prs_merged,
        count(*) as issues_opened,
        cast(0 as bigint) as issues_closed,
        cast(0 as bigint) as stars,
        cast(0 as bigint) as forks

    from {{ ref('issues') }}

    where opened_at is not null

    group by
        repo_name,
        date_format(opened_at, 'yyyyMMdd')

),

issue_closed_daily as (

    select
        md5(repo_name) as repo_id,

        cast(
            date_format(closed_at, 'yyyyMMdd')
            as int
        ) as date_id,

        cast(0 as bigint) as commits,
        cast(0 as bigint) as distinct_committers,
        cast(0 as bigint) as prs_opened,
        cast(0 as bigint) as prs_merged,
        cast(0 as bigint) as issues_opened,
        count(*) as issues_closed,
        cast(0 as bigint) as stars,
        cast(0 as bigint) as forks

    from {{ ref('issues') }}

    where closed_at is not null

    group by
        repo_name,
        date_format(closed_at, 'yyyyMMdd')

),

event_daily as (

    select
        md5(repo_name) as repo_id,

        cast(
            date_format(created_at, 'yyyyMMdd')
            as int
        ) as date_id,

        cast(0 as bigint) as commits,
        cast(0 as bigint) as distinct_committers,
        cast(0 as bigint) as prs_opened,
        cast(0 as bigint) as prs_merged,
        cast(0 as bigint) as issues_opened,
        cast(0 as bigint) as issues_closed,

        sum(
            case
                when event_type = 'WatchEvent' then 1
                else 0
            end
        ) as stars,

        sum(
            case
                when event_type = 'ForkEvent' then 1
                else 0
            end
        ) as forks

    from {{ ref('events') }}

    where event_type in (
        'WatchEvent',
        'ForkEvent'
    )

    group by
        repo_name,
        date_format(created_at, 'yyyyMMdd')

),

unioned as (

    select * from commit_daily

    union all

    select * from pr_opened_daily

    union all

    select * from pr_merged_daily

    union all

    select * from issue_opened_daily

    union all

    select * from issue_closed_daily

    union all

    select * from event_daily

),

daily_rollup as (

    select
        repo_id,
        date_id,

        sum(commits) as commits,
        sum(distinct_committers) as distinct_committers,
        sum(prs_opened) as prs_opened,
        sum(prs_merged) as prs_merged,
        sum(issues_opened) as issues_opened,
        sum(issues_closed) as issues_closed,
        sum(stars) as stars,
        sum(forks) as forks

    from unioned

    group by
        repo_id,
        date_id

)

select
    md5(
        concat_ws(
            '|',
            repo_id,
            cast(date_id as string)
        )
    ) as activity_id,

    repo_id,
    date_id,
    commits,
    distinct_committers,
    prs_opened,
    prs_merged,
    issues_opened,
    issues_closed,
    stars,
    forks

from daily_rollup

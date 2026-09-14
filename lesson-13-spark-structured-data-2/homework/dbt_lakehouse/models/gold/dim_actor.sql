select
    md5(actor_login) as actor_id,
    actor_login,

    case
        when actor_login like '%[bot]' then true
        else false
    end as is_bot,

    min(created_at) as first_seen_at,
    max(created_at) as last_seen_at,
    count(*) as event_count,
    count(distinct repo_name) as distinct_repos

from {{ ref('events') }}

where actor_login is not null

group by
    actor_login

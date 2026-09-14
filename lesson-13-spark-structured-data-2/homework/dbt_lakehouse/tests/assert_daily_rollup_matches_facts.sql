select
    sum(commits) as daily_commits,
    (select count(*) from {{ ref('fact_commit') }}) as fact_commits
from {{ ref('fact_repo_activity_daily') }}
having sum(commits) != (select count(*) from {{ ref('fact_commit') }})

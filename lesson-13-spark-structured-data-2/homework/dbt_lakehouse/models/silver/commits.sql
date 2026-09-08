with push_events as (

    select
        event_id,
        repo_name,
        actor_login as pushed_by,
        created_at as pushed_at,
        from_json(payload, '{{ var("push_schema") }}') as push
    from {{ ref('events') }}
    where event_type = 'PushEvent'

),

exploded_commits as (

    select
        event_id,
        repo_name,
        pushed_by,
        pushed_at,
        push.ref as ref,
        commit
    from push_events
    lateral view explode(push.commits) as commit

),

prepared as (

    select
        commit.sha as commit_sha,
        repo_name,
        pushed_by,
        regexp_replace(ref, '^refs/heads/', '') as branch,
        commit.author.name as author_name,
        commit.author.email as author_email,
        commit.message as message,
        commit.`distinct` as is_distinct,
        pushed_at,
        startswith(commit.message, 'Merge ') as is_merge_commit,
        split(commit.message, '\n')[0] as message_subject,
        length(commit.message) as message_length,
        event_id
    from exploded_commits

),

deduplicated as (

    select *
    from (
        select
            *,
            row_number() over (
                partition by commit_sha
                order by pushed_at asc, event_id asc
            ) as rn
        from prepared
    )
    where rn = 1

)

select
    commit_sha,
    repo_name,
    pushed_by,
    branch,
    author_name,
    author_email,
    message,
    is_distinct,
    pushed_at,
    is_merge_commit,
    message_subject,
    message_length
from deduplicated

with issue_events as (

    select
        event_id,
        repo_name,
        event_type,
        created_at as event_at,

        from_json(
            payload,
            '{{ var("issue_schema") }}'
        ) as issue_data

    from {{ ref('events') }}

    where event_type in (
        'IssuesEvent',
        'IssueCommentEvent'
    )

),

prepared as (

    select
        event_id,
        repo_name,
        event_type,
        event_at,

        issue_data.action as action,
        issue_data.issue.number as issue_number,
        issue_data.issue.title as title,
        issue_data.issue.user.login as author_login,
        issue_data.issue.state as state,

        to_timestamp(issue_data.issue.created_at) as opened_at,
        to_timestamp(issue_data.issue.closed_at) as closed_at,

        issue_data.issue.comments as comments,

        transform(
            issue_data.issue.labels,
            x -> x.name
        ) as label_names

    from issue_events

),

with_comment_count as (

    select
        *,
        sum(
            case
                when event_type = 'IssueCommentEvent' then 1
                else 0
            end
        ) over (
            partition by repo_name, issue_number
        ) as comment_events_seen

    from prepared

),

ranked as (

    select
        *,
        row_number() over (
            partition by repo_name, issue_number
            order by event_at desc, event_id desc
        ) as rn

    from with_comment_count

)

select
    repo_name,
    issue_number,
    title,
    author_login,
    state,
    opened_at,
    closed_at,
    comments,
    label_names,
    comment_events_seen,
    event_at as last_event_at,

    cast(
        (
            unix_timestamp(
                (closed_at)
            )
            - unix_timestamp(opened_at)
        ) / 3600.0
        as double
    ) as hours_to_close

from ranked

where rn = 1

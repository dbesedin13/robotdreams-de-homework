{{ config(materialized='view') }}
-- =====================================================================
-- TASK 1 — stg_events (12 балів). Специфікація: ../../MODELS.md → «stg_events».
-- Прочитати партиційований Parquet і застосувати DQ-фільтри (типи, боти, порожні push).
-- Нижче — лише контракт колонок (заглушка повертає 0 рядків). Замініть тіло запиту.
-- =====================================================================
/*SELECT
    NULL::VARCHAR     AS id,
    NULL::VARCHAR     AS event_type,
    NULL::TIMESTAMPTZ AS created_at,
    NULL::DATE        AS event_date,
    NULL::VARCHAR     AS actor_login,
    NULL::VARCHAR     AS repo_name,
    NULL::BIGINT      AS payload_commit_count,
    NULL::VARCHAR     AS payload_action,
    NULL::VARCHAR     AS payload_ref
WHERE false  -- TODO: read_parquet(... hive_partitioning=true) + DQ-фільтри*/


SELECT
    id,
    event_type,
    created_at,
    event_date,
    actor_login,
    repo_name,
    payload_commit_count,
    payload_action,
    payload_ref
FROM read_parquet('{{ var("events_path") }}', hive_partitioning = true)
WHERE event_type IN (
    'PushEvent',
    'IssuesEvent',
    'PullRequestEvent',
    'WatchEvent',
    'IssueCommentEvent'
)
AND actor_login NOT LIKE '%[bot]'
AND NOT (
    event_type = 'PushEvent'
    AND payload_commit_count = 0
)
-- =====================================================================
-- TASK 3 — daily_activity (12 балів). Специфікація: ../../MODELS.md → «daily_activity».
-- Кількість подій по днях + накопичувальний підсумок: SUM(...) OVER (ORDER BY ...).
-- Контракт колонок нижче; заглушка повертає 0 рядків.
-- =====================================================================
/*SELECT
    NULL::DATE   AS event_date,
    NULL::BIGINT AS events,
    NULL::BIGINT AS running_events
WHERE false  -- TODO: агрегувати stg_events по event_date, потім running total через window-функцію*/


WITH events AS (
SELECT
    event_date,
    COUNT(*) AS events
FROM {{ ref('stg_events') }}
GROUP BY event_date
)
SELECT
    event_date,
    events,
    SUM(events) OVER (
    ORDER BY event_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS running_events
FROM events

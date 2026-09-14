select *
from {{ ref('pull_requests') }}
where merged_at < opened_at
   or closed_at < opened_at

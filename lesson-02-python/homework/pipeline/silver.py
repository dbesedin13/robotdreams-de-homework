"""Silver stage — clean, filter and de-duplicate the bronze events.

TODO (Завдання 2 і 3): реалізуйте build_silver() і write_silver_partitioned().
Контракт: див. CONTRACTS.md → "silver" і "silver partitioned".

build_silver():
  * залиште тільки типи з config.TARGET_EVENT_TYPES
  * приберіть рядки з порожнім/відсутнім repo_name, відсутнім event_id чи created_at
  * гарантуйте унікальність по event_id (.unique(subset=["event_id"]))
  * запишіть у config.SILVER_FILE і поверніть DataFrame

write_silver_partitioned():
  * запишіть silver як Hive-партиціонований датасет за event_type
  * директорія: config.SILVER_PARTITIONED_DIR
  * підказка: df.write_parquet(dir, partition_by="event_type")
"""

from __future__ import annotations

import polars as pl

from . import config

from pathlib import Path


def build_silver(bronze_df: pl.DataFrame) -> pl.DataFrame:
    #raise NotImplementedError("Завдання 2: реалізуйте silver згідно з CONTRACTS.md")
    df = (
        bronze_df
        .filter(
            pl.col("event_type").is_in(config.TARGET_EVENT_TYPES)
        )
        .filter(
            pl.col("repo_name").is_not_null()
        )
        .filter(
            pl.col("event_id").is_not_null()
        )
        .filter(
            pl.col("created_at").is_not_null()
        )
        .filter(
            pl.col("repo_name") != ""
        )
        .unique(subset="event_id")
    )

    Path(config.SILVER_FILE).parent.mkdir(parents=True, exist_ok=True)
    df.write_parquet(config.SILVER_FILE)
    
    return df


if __name__ == "__main__":
    df = build_silver()

def write_silver_partitioned(silver: pl.DataFrame) -> None:
    raise NotImplementedError("Завдання 3: запишіть партиціонований silver за event_type")

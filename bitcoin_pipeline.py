#!/usr/bin/env python
# coding: utf-8

import io
import logging
from datetime import date, timedelta

import boto3
from google.cloud import bigquery
from tqdm import tqdm

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

# --- Config ---
MODE = "daily"           # "backfill" or "daily"
START_DATE = "2009-01-03"  # backfill start (Bitcoin genesis block)
BUCKET = "input-btc-bq"  # update with full name after: terraform output input_btc_bq_bucket_name
AWS_REGION = "ap-southeast-1"
# --------------

BQ_QUERY = """
    SELECT *
    FROM `bigquery-public-data.crypto_bitcoin.transactions`
    WHERE block_timestamp >= TIMESTAMP('{date}')
      AND block_timestamp < TIMESTAMP_ADD(TIMESTAMP('{date}'), INTERVAL 1 DAY)
"""

S3_KEY = "bitcoin/transactions/date={date}/data.parquet"


def s3_key_exists(s3_client, bucket, key):
    try:
        s3_client.head_object(Bucket=bucket, Key=key)
        return True
    except Exception:
        return False


def extract_and_upload(target_date: date, bq_client, s3_client):
    date_str = target_date.isoformat()
    key = S3_KEY.format(date=date_str)

    if s3_key_exists(s3_client, BUCKET, key):
        log.info(f"Skipping {date_str} — already in S3")
        return

    log.info(f"Querying BigQuery for {date_str}...")
    df = bq_client.query(BQ_QUERY.format(date=date_str)).to_dataframe()

    if df.empty:
        log.info(f"No data for {date_str}, skipping")
        return

    log.info(f"Uploading {len(df)} rows to s3://{BUCKET}/{key}")
    buffer = io.BytesIO()
    df.to_parquet(buffer, index=False)
    buffer.seek(0)

    s3_client.put_object(Bucket=BUCKET, Key=key, Body=buffer.getvalue())
    log.info(f"Done {date_str}")


def main():
    bq_client = bigquery.Client()
    s3_client = boto3.client("s3", region_name=AWS_REGION)

    yesterday = date.today() - timedelta(days=1)

    if MODE == "daily":
        extract_and_upload(yesterday, bq_client, s3_client)

    elif MODE == "backfill":
        start = date.fromisoformat(START_DATE)
        dates = [start + timedelta(days=i) for i in range((yesterday - start).days + 1)]
        for d in tqdm(dates, desc="Backfill"):
            extract_and_upload(d, bq_client, s3_client)


if __name__ == "__main__":
    main()

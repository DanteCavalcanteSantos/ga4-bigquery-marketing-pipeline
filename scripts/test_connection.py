"""Connection test: dry run against the GA4 public sample (costs nothing)."""

from google.cloud import bigquery

PROJECT_ID = "portfolio-marketing-digital"

QUERY = """
SELECT event_name, COUNT(*) AS events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX = '20210131'
GROUP BY event_name
ORDER BY events DESC
"""

client = bigquery.Client(project=PROJECT_ID)

job_config = bigquery.QueryJobConfig(dry_run=True, use_query_cache=False)
job = client.query(QUERY, job_config=job_config)

mib = job.total_bytes_processed / 1024**2
print(f"Connected to project: {client.project}")
print(f"Dry run OK. This query would read {mib:.2f} MiB.")

"""Local runner utilities for the monitoring Slack alert Lambdas.

This package exists purely to make the Lambda handlers in sibling folders
(e.g. auth0_log_stream_alert/src/auth0_log_stream_alert.py) runnable locally.

Nothing in this package is packaged/deployed to AWS by Terraform.
"""

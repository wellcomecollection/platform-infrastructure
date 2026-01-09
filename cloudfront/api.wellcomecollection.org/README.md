# Slack alerter for CloudFront logs from the API

The Slack alerter monitors CloudFront logs for 5xx responses from the API distribution
and sends a Slack alert if the percentage of _interesting_ 5xx responses exceeds a given threshold.

Interesting 5xx responses are defined as those that are not from known bots or health checks.
## Testing the slack alerter for CloudFront

You can run a local version of the slack alerter by running the following command from this directory:

```bash
docker build . -f Dockerfile.rie-5xx-reporter -t send-slack-test
docker run -p 9000:8080 -v ~/.aws:/root/.aws -e AWS_PROFILE=platform-developer -e THRESHOLD_PERCENT=0.1 -e WEBHOOK_URL=example.com send-slack-test 
```

You will need to be logged in to AWS with a profile that has permission to read the logs from s3.
You can then send a test request to the local server thus:

```bash
sh post-to-rie.sh api.wellcomecollection.org/EIF11EK4Z5JS8.2026-01-08-12.9690b66d.gz
```

The argument is the path to a CloudFront log file in s3. You can find recent log files in the `wellcomecollection-api-logs` bucket.


This allows you to try out any changes to filtering or thresholds against real data before deploying them to Lambda.
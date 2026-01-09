curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d '{
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "awsRegion": "eu-west-1",
      "eventTime": "2024-06-01T12:00:00.000Z",
      "eventName": "ObjectCreated:Put",
      "s3": {
        "bucket": {
          "name": "wellcomecollection-api-cloudfront-logs"
        },
        "object": {
          "key": "'${1}'"
        }
      }
    }
  ]
}'
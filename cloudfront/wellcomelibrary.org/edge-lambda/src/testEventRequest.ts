import { CloudFrontRequestEvent } from 'aws-lambda';

// This event structure was sourced from the AWS docs as below.
// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html#example-origin-request
const request = (
  uri: string,
  querystring?: string
): CloudFrontRequestEvent => ({
  Records: [
    {
      cf: {
        config: {
          distributionId: 'EXAMPLE',
          distributionDomainName: '',
          requestId: '',
          eventType: 'origin-request',
        },
        request: {
          uri,
          querystring: querystring || '',
          method: 'GET',
          clientIp: '2001:cdba::3257:9652',
          headers: {},
        },
      },
    },
  ],
});

export default request;

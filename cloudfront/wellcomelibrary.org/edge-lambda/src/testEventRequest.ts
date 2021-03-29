import { CloudFrontHeaders, CloudFrontRequestEvent } from 'aws-lambda';
import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';

// This event structure was sourced from the AWS docs as below.
// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html#example-origin-request
export const createCloudFrontRequestEvent = (
  uri: string,
  querystring?: string,
  headers: CloudFrontHeaders = {}
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
        request: createCloudFrontRequest(uri, querystring, headers),
      },
    },
  ],
});

export const createCloudFrontRequest = (
  uri: string,
  querystring?: string,
  headers: CloudFrontHeaders = {}
) => {
  return {
    uri: uri,
    querystring: querystring || '',
    method: 'GET',
    clientIp: '2001:cdba::3257:9652',
    headers: headers,
  } as CloudFrontRequest;
};

export default createCloudFrontRequestEvent;

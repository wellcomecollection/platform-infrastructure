import { CloudFrontRequestEvent } from 'aws-lambda';

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

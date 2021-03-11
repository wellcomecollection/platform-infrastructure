import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';

export function expectedRedirect(uri: string): CloudFrontResultResponse {
  return {
    status: '302',
    statusDescription: `Redirecting to ${uri}`,
    headers: {
      location: [
        {
          key: 'Location',
          value: uri,
        },
      ],
    },
  } as CloudFrontResultResponse;
}

export function expectedPassthru(uri: string): CloudFrontRequest {
  return {
    clientIp: '2001:cdba::3257:9652',
    headers: {
      host: [
        {
          key: 'host',
          value: 'wellcomelibrary.org',
        },
      ],
    },
    method: 'GET',
    querystring: '',
    uri: uri,
  } as CloudFrontRequest;
}

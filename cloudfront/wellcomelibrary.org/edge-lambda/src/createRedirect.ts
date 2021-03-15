import { CloudFrontResultResponse } from 'aws-lambda/common/cloudfront';

export function createRedirect(url: URL, cors: boolean = false) {
  const locationHeaders = {
    location: [
      {
        key: 'Location',
        value: url.toString(),
      },
    ],
  }

  const corsHeaders = {
    'access-control-allow-origin': [
      {
        key: 'Access-Control-Allow-Origin',
        value: '*',
      },
    ]
  }

  const headers = cors ? {...locationHeaders, ...corsHeaders} : locationHeaders;

  return {
    status: '302',
    statusDescription: `Redirecting to ${url}`,
    headers: headers,
  } as CloudFrontResultResponse;
}
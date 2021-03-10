import { CloudFrontResultResponse } from 'aws-lambda/common/cloudfront';

export function redirect(uri: string) {
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

import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';
import { createRedirect } from './redirectHelpers';

type Scheme = 'https' | 'http';

export function redirectToRoot(request: CloudFrontRequest) {
  const requiredHeaders = ['host', 'cloudfront-forwarded-proto'];

  const missingHeaders = requiredHeaders
    .map((header) => (header in request.headers ? undefined : header))
    .filter((header) => header !== undefined);

  const hasMissingHeaders = missingHeaders.length >= 1;

  if (hasMissingHeaders) {
    console.error(
      `Request missing headers ${missingHeaders}, (required: ${requiredHeaders})`
    );
  } else {
    const requestHost = request.headers.host[0].value;
    const scheme = request.headers['cloudfront-forwarded-proto'][0]
      .value as Scheme;

    const isHttp = scheme === 'http';
    const isWww = requestHost.startsWith('www.');

    if (isWww) {
      const rootRequestHost = requestHost.replace('www.', '');
      return createRedirect(
        new URL(`https://${rootRequestHost}${request.uri}`),
        true
      );
    }

    if (isHttp) {
      return createRedirect(
        new URL(`https://${requestHost}${request.uri}`),
        true
      );
    }
  }
}

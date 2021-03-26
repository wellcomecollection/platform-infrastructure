import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';
import { createRedirect } from './redirectHelpers';


type Scheme = 'https' | 'http'

export function redirectToRoot(request: CloudFrontRequest) {
  if (request.headers.host?.length === 1) {
    const requestHost = request.headers.host[0].value;
    const scheme = request.headers['cloudfront-forwarded-proto'][0].value as Scheme;

    const isHttp = scheme === 'http'
    const isWww = requestHost.startsWith('www.')

    if (isWww) {
      const rootRequestHost = requestHost.replace('www.', '');
      return createRedirect(
          new URL(`https://${rootRequestHost}${request.uri}`)
      );
    }

    if (isHttp) {
      return createRedirect(
          new URL(`https://${requestHost}${request.uri}`)
      );
    }
  }
}

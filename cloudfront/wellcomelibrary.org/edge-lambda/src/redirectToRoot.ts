import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';
import { createRedirect } from './createRedirect';

export function redirectToRoot(request: CloudFrontRequest) {
  if (request.headers.host?.length === 1) {
    const requestHost = request.headers.host[0].value;

    if (requestHost.startsWith('www.')) {
      const rootRequestHost = requestHost.replace('www.', '');
      return createRedirect(
        new URL(`https://${rootRequestHost}${request.uri}`)
      );
    }
  }
}

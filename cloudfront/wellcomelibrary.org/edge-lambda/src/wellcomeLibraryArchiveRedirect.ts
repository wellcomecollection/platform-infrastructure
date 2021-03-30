import { CloudFrontRequestEvent, Context } from 'aws-lambda';
import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';
import { redirectToRoot } from './redirectToRoot';


export const requestHandler = async (
  event: CloudFrontRequestEvent,
  _: Context
) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  const rootRedirect = redirectToRoot(request);
  if (rootRedirect) {
    return rootRedirect;
  }

  request.headers.host = [{ key: 'host', value: 'archives.wellcomelibrary.org' }];

  return request;
};

import { CloudFrontRequestEvent, Context } from 'aws-lambda';
import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';
import { wellcomeCollectionRedirect } from './redirectHelpers';
import { redirectToRoot } from './redirectToRoot';

// This lambda is intended to be added to the default behaviour in CloudFront
// If there are no behaviour matches then simply pass through to wellcomecollection.org
export const requestHandler = async (
  event: CloudFrontRequestEvent,
  _: Context
) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  const rootRedirect = redirectToRoot(request);
  if (rootRedirect) {
    return rootRedirect;
  }

  return wellcomeCollectionRedirect('/');
};

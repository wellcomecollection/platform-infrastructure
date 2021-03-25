import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';
import { createRedirect, createServerError } from './redirectHelpers';
import { CloudFrontRequestEvent, Context } from 'aws-lambda';

export const blogHost = 'https://blog.wellcomelibrary.org';
export const waybackPrefix = 'https://wayback.archive-it.org/16107/';

export const requestHandler = async (
  event: CloudFrontRequestEvent,
  _: Context
) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;
  const redirectionTarget = `${blogHost}${request.uri}`;

  const errorSuffix = 'Trying to redirect ' + redirectionTarget;

  if (request.headers.host?.length !== 1) {
    return createServerError(Error('No host header found: ' + errorSuffix));
  }

  const requestHost = request.headers.host[0].value;

  if (!requestHost.startsWith('blog.')) {
    return createServerError(
      Error(
        `Host header ${requestHost} does not start with 'blog.': ` + errorSuffix
      )
    );
  }

  return createRedirect(new URL(`${waybackPrefix}${blogHost}${request.uri}`));
};

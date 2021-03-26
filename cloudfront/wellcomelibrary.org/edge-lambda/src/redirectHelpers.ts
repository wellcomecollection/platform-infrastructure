import { CloudFrontResultResponse } from 'aws-lambda/common/cloudfront';

const wellcomeCollectionHost = 'https://wellcomecollection.org';

export const wellcomeCollectionNotFoundRedirect = createRedirect(
  new URL(`${wellcomeCollectionHost}/works/not-found`)
);

export function wellcomeCollectionRedirect(path: string) {
  const wellcomeCollectionUrl = new URL(`${wellcomeCollectionHost}${path}`);
  return createRedirect(wellcomeCollectionUrl);
}

export function createRedirect(url: URL) {
  const locationHeaders = {
    location: [
      {
        key: 'Location',
        value: url.toString(),
      },
    ],
  };

  const corsHeaders = {
    'access-control-allow-origin': [
      {
        key: 'Access-Control-Allow-Origin',
        value: '*',
      },
    ],
  };

  const headers = { ...locationHeaders, ...corsHeaders };

  return {
    status: '302',
    statusDescription: `Redirecting to ${url}`,
    headers: headers,
  } as CloudFrontResultResponse;
}

export function createServerError(error: Error) {
  return {
    status: '500',
    statusDescription: error.message,
  } as CloudFrontResultResponse;
}

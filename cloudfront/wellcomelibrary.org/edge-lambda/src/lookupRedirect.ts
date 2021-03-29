import { CloudFrontResultResponse } from 'aws-lambda';
import { createRedirect } from './redirectHelpers';

export function lookupRedirect(
  redirects: Record<string, string>,
  uri: string
): CloudFrontResultResponse | undefined {
  // Strip trailing slash
  const cleanUri = uri.replace(/\/$/, '');

  // If path is at base, redirect to wellcomecollection.org
  if(uri === '/' || uri === '') {
    return createRedirect(new URL('https://wellcomecollection.org/'));
  }

  if (cleanUri in redirects) {
    return createRedirect(new URL(redirects[cleanUri]));
  }
}

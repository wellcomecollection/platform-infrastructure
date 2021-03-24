import { CloudFrontResultResponse } from 'aws-lambda';
import { createRedirect } from './redirectHelpers';

export function lookupRedirect(
  redirects: Record<string, string>,
  uri: string
): CloudFrontResultResponse | undefined {
  // Strip trailing slash
  const cleanUri = uri.replace(/\/$/, '');
  if (cleanUri in redirects) {
    return createRedirect(new URL(redirects[cleanUri]));
  }
}

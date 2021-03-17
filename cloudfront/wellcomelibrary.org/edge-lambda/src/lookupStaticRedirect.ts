import { CloudFrontResultResponse } from 'aws-lambda';
import { createRedirect } from './redirectHelpers';

export function lookupStaticRedirect(
  staticRedirects: Record<string, string>,
  uri: string
): CloudFrontResultResponse | undefined {
  // Strip trailing slash
  const cleanUri = uri.replace(/\/$/, '');
  if (cleanUri in staticRedirects) {
    return createRedirect(new URL(staticRedirects[cleanUri]));
  }
}

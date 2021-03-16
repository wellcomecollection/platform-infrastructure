import { CloudFrontResultResponse } from 'aws-lambda';
import { createRedirect } from './createRedirect';

export function lookupStaticRedirect(
  staticRedirects: Record<string, string>,
  uri: string
): CloudFrontResultResponse | undefined {
  // Strip trailing slash
  const cleanUri = uri.replace(/\/$/, '');
  if (cleanUri in staticRedirects) {
    return createRedirect(staticRedirects[cleanUri]);
  }
}

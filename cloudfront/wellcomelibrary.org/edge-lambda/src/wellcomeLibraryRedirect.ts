import { CloudFrontRequestEvent, Context } from 'aws-lambda';
import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';
import { getBnumberFromPath } from './paths';
import { getWork } from './bnumberToWork';
import {
  createRedirect,
  wellcomeCollectionNotFoundRedirect,
  wellcomeCollectionRedirect,
  createServerError,
} from './redirectHelpers';
import { redirectToRoot } from './redirectToRoot';
import { lookupRedirect } from './lookupRedirect';
import { wlorgpLookup } from './wlorgpLookup';

import rawStaticRedirects from './staticRedirects.json';
const staticRedirects = rawStaticRedirects as Record<string, string>;

async function getWorksRedirect(
  uri: string
): Promise<CloudFrontResultResponse> {
  // Try and find b-number in item path
  const bNumberResult = getBnumberFromPath(uri);

  if (bNumberResult instanceof Error) {
    console.error(bNumberResult);
    return wellcomeCollectionNotFoundRedirect;
  }

  // Find corresponding work id
  const work = await getWork(bNumberResult);

  if (work instanceof Error) {
    console.error(work);
    return wellcomeCollectionNotFoundRedirect;
  }

  return wellcomeCollectionRedirect(`/works/${work.id}`);
}

async function getApiRedirects(uri: string): Promise<CloudFrontResultResponse> {
  const apiRedirectUri = await wlorgpLookup(uri);

  if (apiRedirectUri instanceof Error) {
    console.error(apiRedirectUri);
    return createServerError(apiRedirectUri);
  }

  return createRedirect(apiRedirectUri, true);
}

async function redirectRequestUri(
  request: CloudFrontRequest
): Promise<undefined | CloudFrontResultResponse> {
  let uri = request.uri;
  if (request.querystring) {
    uri = `${uri}?${request.querystring}`;
  }

  const itemPathRegExp: RegExp = /^\/item\/.*/;
  const eventsPathRegExp: RegExp = /^\/events(\/)?.*/;
  const apiPathRegExp: RegExp = /^\/(iiif|service|ddsconf|dds-static|annoservices)\/.*/;
  const staticRedirect = lookupRedirect(staticRedirects, uri);

  if (staticRedirect) {
    return staticRedirect;
  } else if (uri.match(itemPathRegExp)) {
    return getWorksRedirect(uri);
  } else if (uri.match(eventsPathRegExp)) {
    return wellcomeCollectionRedirect('/whats-on');
  } else if (uri.match(apiPathRegExp)) {
    return getApiRedirects(uri);
  }
}

export const requestHandler = async (
  event: CloudFrontRequestEvent,
  _: Context
) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  const rootRedirect = redirectToRoot(request);
  if (rootRedirect) {
    return rootRedirect;
  }

  const requestRedirect = await redirectRequestUri(request);

  if (requestRedirect) {
    return requestRedirect;
  }

  // If we've matched nothing so far then set the host header for Wellcome Library
  // In future we may want to redirect to wellcomecollection.org if we find no match
  request.headers.host = [{ key: 'host', value: 'wellcomelibrary.org' }];

  return request;
};

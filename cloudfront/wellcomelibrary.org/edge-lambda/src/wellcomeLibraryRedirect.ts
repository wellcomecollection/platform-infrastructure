import { CloudFrontRequestEvent, Context } from 'aws-lambda';
import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';
import { getBnumberFromPath } from './paths';
import {
  createRedirect,
  getSierraIdentifierRedirect,
  wellcomeCollectionNotFoundRedirect,
  wellcomeCollectionRedirect,
} from './redirectHelpers';
import { redirectToRoot } from './redirectToRoot';
import { lookupRedirect } from './lookupRedirect';
import { wlorgpLookup } from './wlorgpLookup';

import rawStaticRedirects from './staticRedirects.json';
const staticRedirects = rawStaticRedirects as Record<string, string>;

async function getWorksRedirect(
  uri: string
): Promise<CloudFrontResultResponse> {
  const sierraIdentifier = getBnumberFromPath(uri);

  return getSierraIdentifierRedirect(sierraIdentifier);
}

async function getApiRedirects(
  uri: string
): Promise<CloudFrontResultResponse | undefined> {
  const apiRedirectUri = await wlorgpLookup(uri);

  if (apiRedirectUri instanceof Error) {
    console.error(apiRedirectUri);
    return Promise.resolve(undefined);
  }

  return createRedirect(apiRedirectUri);
}

async function redirectRequestUri(
  request: CloudFrontRequest
): Promise<undefined | CloudFrontResultResponse> {
  let uri = request.uri;
  if (request.querystring) {
    uri = `${uri}?${request.querystring}`;
  }

  const itemPathRegExp: RegExp = /^\/(item|player)\/.*/;
  const eventsPathRegExp: RegExp = /^\/events(\/)?.*/;
  const apiPathRegExp: RegExp = /^\/(iiif|service|ddsconf|dds-static|annoservices)\/.*/;
  const collectionsBrowseExp: RegExp = /^\/collections\/browse(\/)?.*/;
  const staticRedirect = lookupRedirect(staticRedirects, uri);

  if (staticRedirect) {
    return staticRedirect;
  } else if (uri.match(itemPathRegExp)) {
    return getWorksRedirect(uri);
  } else if (uri.match(collectionsBrowseExp)) {
    return wellcomeCollectionRedirect('/collections');
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

  // If we've matched nothing we redirect to wellcomecollection.org
  console.warn(`Unable to redirect request ${JSON.stringify(event.Records[0].cf.request)}`);
  return wellcomeCollectionRedirect('/');
};

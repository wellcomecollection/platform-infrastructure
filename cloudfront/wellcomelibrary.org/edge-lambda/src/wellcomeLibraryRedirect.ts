import { CloudFrontRequestEvent, Context } from 'aws-lambda';
import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';
import { getBnumberFromPath } from './paths';
import { getWork } from './bnumberToWork';
import { createRedirect } from './createRedirect';
import { redirectToRoot } from './redirectToRoot';
import {wlgorpLookup} from "./wlgorpLookup";

const wellcomeCollectionHost = 'https://wellcomecollection.org';
const notFoundRedirect = createRedirect(
    new URL(`${wellcomeCollectionHost}/works/not-found`)
);

async function getWorksRedirect(uri: string): Promise<CloudFrontResultResponse> {
  // Try and find b-number in item path
  const bNumberResult = getBnumberFromPath(uri);

  if (bNumberResult instanceof Error) {
    console.error(bNumberResult);
    return notFoundRedirect;
  }

  // Find corresponding work id
  const bNumber = bNumberResult;
  const work = await getWork(bNumber);

  if (work instanceof Error) {
    console.error(work);
    return notFoundRedirect;
  }

  return createRedirect(new URL(`${wellcomeCollectionHost}/works/${work.id}`));
}

function createServerError(error: Error) {
  return {
    status: '500',
    statusDescription: error.message,
  } as CloudFrontResultResponse;
}

async function getApiRedirects(uri: string): Promise<CloudFrontResultResponse> {
  const apiRedirectUri = await wlgorpLookup(uri);

  if (apiRedirectUri instanceof Error) {
    console.error(apiRedirectUri);
    return createServerError(apiRedirectUri);
  }

  return createRedirect(apiRedirectUri, true);
}

async function rewriteRequestUri(
  uri: string
): Promise<undefined | CloudFrontResultResponse> {
  const itemPathRegExp: RegExp = /^\/item\/.*/;
  const eventsPathRegExp: RegExp = /^\/events(\/)?.*/;
  const apiPathRegExp: RegExp = /^\/(iiif|service|ddsconf|dds-static|annoservices|goobipdf)\/.*/;

  if (uri.match(itemPathRegExp)) {
    return getWorksRedirect(uri);
  } else if(uri.match(eventsPathRegExp)) {
    return createRedirect(new URL(`${wellcomeCollectionHost}/whats-on`));
  } else if(uri.match(apiPathRegExp)) {
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

  const requestRedirect = await rewriteRequestUri(request.uri);

  if (requestRedirect) {
    return requestRedirect;
  }

  // If we've matched nothing so far then set the host header for Wellcome Library
  // In future we may want to redirect to wellcomecollection.org if we find no match
  request.headers.host = [{ key: 'host', value: 'wellcomelibrary.org' }];

  return request;
};

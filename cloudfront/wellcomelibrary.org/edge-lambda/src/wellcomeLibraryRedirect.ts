import { CloudFrontRequestEvent, Context } from 'aws-lambda';
import { CloudFrontRequest, CloudFrontResultResponse } from 'aws-lambda/common/cloudfront';
import { getBnumberFromPath } from './paths';
import { getWork } from './bnumberToWork';
import { redirect } from "./redirect";

async function rewriteRequestUri(uri: string): Promise<undefined | CloudFrontResultResponse> {
  const itemPathRegExp: RegExp = /^\/item\/.*/;
  const wellcomeCollectionHost = 'https://wellcomecollection.org'
  const notFoundRedirect = redirect(`${wellcomeCollectionHost}/works/not-found`)

  if (uri.match(itemPathRegExp)) {
    // Try and find b-number in item path
    const bNumberResult = getBnumberFromPath(uri);

    if(bNumberResult instanceof Error) {
      return notFoundRedirect;
    }

    // Find corresponding work id
    const bNumber = bNumberResult;
    const work = await getWork(bNumber);

    if(work instanceof Error) {
        return notFoundRedirect;
    }

    return redirect(`${wellcomeCollectionHost}/works/${work.id}`);
  }
}

export const requestHandler = async (event: CloudFrontRequestEvent, _: Context) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  // Redirect www. -> to root
  if(request.headers.host && request.headers.host.length == 1) {
    const requestHost =  request.headers.host[0].value

    if (requestHost.startsWith('www.')) {
      const rootRequestHost = requestHost.replace('www.','');
      return Promise.resolve(redirect(`https://${rootRequestHost}${request.uri}`));
    }
  }

  // TODO: Work out if we want to split this into 2 lambdas - one for the base host rewrite
  // and one per path!
  // TODO: tests for paths.js (and any other modules)

  const requestRedirect = await rewriteRequestUri(request.uri);

  if(requestRedirect) {
      return requestRedirect;
  }

  request.headers['host'] = [{ key: 'host', value: 'wellcomelibrary.org' }];

  return request;
};

import { CloudFrontRequestEvent, Context } from 'aws-lambda';
import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';

import { getBnumberFromPath } from './paths'
import { getWork } from './api'

async function rewriteRequestUri(uri: string) {
  const itemPathRegExp: RegExp = /^\/item\/.*/;
  if (uri.match(itemPathRegExp)) {
    // Try and find b-number in item path
    const bNumberResult = getBnumberFromPath(uri);

    if(bNumberResult instanceof Error) {
      return `/works/not-found`;
    }

    // Find corresponding work id
    const bNumber = bNumberResult;
    const getWorkResult = await getWork(bNumber);

    if(getWorkResult instanceof Error) {
      return `/works/not-found`;
    }

    const work = getWorkResult;
    return `/works/${work.id}`;
  } else {
    return uri;
  }
}

export const request = async (event: CloudFrontRequestEvent, _: Context) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;
  request.uri = await rewriteRequestUri(request.uri);

  return request;
};

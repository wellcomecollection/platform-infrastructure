import { CloudFrontRequestEvent, Context } from 'aws-lambda';
import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';
import { 
  getSierraIdentifierRedirect,
  wellcomeCollectionRedirect
} from './redirectHelpers';
import { calcCheckDigit, GetBNumberResult } from './paths';

export function getBnumberFromPath(path: string): GetBNumberResult {
  if (!path.startsWith('/iii/encore/record/')) {
    return Error(`Path ${path} does not start with /iii/encore/record/`);
  }
  const pathPath = path.split('/')[4];

  const sierraIdRegexp = /^C__Rb([0-9]{7})/;

  if (!sierraIdRegexp.test(pathPath)) {
    return Error(`b number in ${path} (${pathPath}) does not match ${sierraIdRegexp}`);
  }

  const sierraIdentifier = pathPath.toLowerCase().substr(5, 11);
  const sierraSystemNumber = `b${sierraIdentifier}${calcCheckDigit(
    parseInt(sierraIdentifier)
  )}`;

  return {
    sierraIdentifier: sierraIdentifier,
    sierraSystemNumber: sierraSystemNumber,
  };
}

async function getWorksRedirect(
  uri: string
): Promise<CloudFrontResultResponse> {
  const sierraIdentifier = getBnumberFromPath(uri);

  return getSierraIdentifierRedirect(sierraIdentifier);
}

export const requestHandler = async (
  event: CloudFrontRequestEvent,
  _: Context
) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  request.headers.host = [{ key: 'host', value: 'search.wellcomelibrary.org' }];

  const uri = request.uri;

  // URLs like https://search.wellcomelibrary.org/iii/encore/record/C__Rb2475299
  const bibPathRegExp: RegExp = /\/iii\/encore\/record\/C__Rb[0-9]{7}.*/;

  if (uri.match(bibPathRegExp)) {
    return getWorksRedirect(uri);
  }

  // If we've matched nothing we redirect to wellcomecollection.org/collections/
  console.warn(`Unable to redirect request ${JSON.stringify(event.Records[0].cf.request)}`);
  return wellcomeCollectionRedirect('/collections/');
};

import { CloudFrontRequestEvent, Context } from 'aws-lambda';
import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';
import querystring from 'querystring';
import { wellcomeCollectionRedirect } from './redirectHelpers';
import { findWorkWithIdentifierValue } from './catalogueApi';

async function getWorkWithId(term: string) {
  const work = await findWorkWithIdentifierValue(term);
  if (work) {
    return wellcomeCollectionRedirect(`/works/${work.id}`);
  }
}

async function redirectRequestUri(
  request: CloudFrontRequest
): Promise<undefined | CloudFrontResultResponse> {
  const qs = querystring.parse(request.querystring);
  const dsqItem = qs.dsqItem ? qs.dsqItem.toString() : undefined;
  const dsqSearch = qs.dsqSearch ? qs.dsqSearch.toString() : undefined;
  const dsqSearchTermsMatch = dsqSearch
    ? dsqSearch.match(/'([^']*)'/g)
    : undefined;
  // The dserve app puts all test it's searching for in the format of `(Field='{term}')`
  // so we just search for anything between `'`
  const dsqSearchTerms = dsqSearchTermsMatch
    ? dsqSearchTermsMatch.map((term) => term.replace(/'/g, '')).join(' ')
    : undefined;
  const search = dsqItem ?? dsqSearchTerms;

  if (search) {
    const work = await getWorkWithId(search);
    return work ?? wellcomeCollectionRedirect(`/works?query=${search}`);
  }
}

export const requestHandler = async (
  event: CloudFrontRequestEvent,
  _: Context
) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  const requestRedirect = await redirectRequestUri(request);

  if (requestRedirect) {
    return requestRedirect;
  }

  // If we've matched nothing so far then set the host header for Wellcome Library
  // In future we may want to redirect to wellcomecollection.org if we find no match
  request.headers.host = [
    { key: 'host', value: 'archive.wellcomelibrary.org' },
  ];

  return request;
};

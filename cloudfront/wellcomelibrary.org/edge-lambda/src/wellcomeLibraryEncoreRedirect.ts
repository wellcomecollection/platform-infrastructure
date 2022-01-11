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
import querystring from 'querystring';

type EncorePathComponent = {
  letter: string;
  contents?: string;
};

// Parses the final path part of an Encore URL into 'components'.
//
// I'm having to guess at how Encore URLs work here -- it looks like the
// final part is a collection of components separated by a double underscore, and
// the first letter of each component tells you waht that component is.
// e.g. if we look at a more complex URL:
//
//    /iii/encore/record/C__Rb3153458__Sdrugscope__P0%2C1__Orightresult__U__X7
//
// Then we have:
//
//    R = record = b3153458
//    S = search = drugscope
//    P = ???    = 0,1
//    O = ???    = rightresult
//    U = ???    = <empty>
//    X = ???    = 7
//
// and for these URLs, we want the component that starts with 'S'.
//
// This function takes the part after the final slash.
//
// Note: components are returned as they appear in the URL; this function does *not*
// do any URL decoding.
//
function parseEncorePathComponents(finalPathPart: string): EncorePathComponent[] {
  return finalPathPart.split('__')
    .map(component => {
      const letter = component.substring(0, 1);
      const contents = component.substring(1, );
      
      return {
        letter: letter,
        contents: contents.length > 0 ? contents : undefined,
      };
    })
}

export function getBnumberFromEncorePath(path: string): GetBNumberResult {
  if (!path.startsWith('/iii/encore/record/')) {
    return Error(`Path ${path} does not start with /iii/encore/record/`);
  }

  const finalPathPart = path.split('/')[4];
  const components = parseEncorePathComponents(finalPathPart);
  
  const sierraBibRegexp = /^b([0-9]{7})$/;

  // If defined, this will be something like '1234567'
  const bnumber = components
    .filter(c => c.letter == 'R')
    .find(c => c.contents && sierraBibRegexp.test(c.contents))
    ?.contents?.substring(1, );

  if (!bnumber) {
    return Error(`Could not find bib identifier in path ${path}`);
  }

  return {
    sierraIdentifier: bnumber,
    sierraSystemNumber: `b${bnumber}${calcCheckDigit(parseInt(bnumber))}`,
  };
}

async function getWorksRedirect(
  path: string
): Promise<CloudFrontResultResponse> {
  const sierraIdentifier = getBnumberFromEncorePath(path);

  return getSierraIdentifierRedirect(sierraIdentifier);
}

function getSearchRedirect(
  path: string,
  qs: querystring.ParsedUrlQuery
): CloudFrontResultResponse | Error {
  if (!path.startsWith('/iii/encore/search')) {
    return Error(`Path ${path} does not start with /iii/encore/search`);
  }
  
  // For URLs like /iii/encore/search?target=erythromelalgia&submit=Search
  if (qs['submit'] === 'Search' && qs['target']) {
    return wellcomeCollectionRedirect(`/works?query=${qs['target']}`)
  }

  // For URLs like /iii/encore/search/C__Srosalind%20paget
  const finalPathPart = path.split('/')[4];
  const components = parseEncorePathComponents(finalPathPart);

  const searchTerms = components
    .find(c => c.letter == 'S')
    ?.contents;

  if (searchTerms) {
    return wellcomeCollectionRedirect(`/works?query=${searchTerms}`);
  }

  // If we've matched nothing we redirect to the top-level collections page
  console.warn(`Could not extract search term from path=${path}, qs=${qs}`);
  return wellcomeCollectionRedirect('/collections/');
}

export const requestHandler = async (
  event: CloudFrontRequestEvent,
  _: Context
) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  request.headers.host = [{ key: 'host', value: 'search.wellcomelibrary.org' }];

  const path = request.uri;
  const qs: querystring.ParsedUrlQuery = querystring.parse(request.querystring);

  // URLs like https://search.wellcomelibrary.org/iii/encore/record/C__Rb2475299
  const bibPathRegExp: RegExp = /^\/iii\/encore\/record\/C__Rb[0-9]{7}.*/;

  // URLs like https://search.wellcomelibrary.org/iii/encore/myaccount?suite=cobalt&lang=eng
  const accountPathRegExp: RegExp = /^\/iii\/encore\/myaccount.*/;

  // URLs like search.wellcomelibrary.org/iii/encore/search/C__Srosalind%20paget
  //
  // Note: the omission of the trailing slash is deliberate, because some Encore URLs
  // only have '/search' as the path and then put the search terms in the query string.
  const searchPathRegExp: RegExp = /^\/iii\/encore\/search.*/;

  if (path.match(bibPathRegExp)) {
    return getWorksRedirect(path);
  } else if (path.match(accountPathRegExp)) {
    return wellcomeCollectionRedirect('/account');
  } else if (path.match(searchPathRegExp)) {
    return getSearchRedirect(path, qs);
  }

  // If we've matched nothing we redirect to the top-level collections page
  console.warn(`Unable to redirect request ${JSON.stringify(event.Records[0].cf.request)}`);
  return wellcomeCollectionRedirect('/collections/');
};

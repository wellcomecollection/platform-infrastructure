import * as origin from '../wellcomeLibraryEncoreRedirect';
import testRequest from './testEventRequest';
import { Context } from 'aws-lambda';
import { results, resultWithIdentifier } from './catalogueApiFixtures';
import { expectedRedirect } from './testHelpers';
import axios from 'axios';
import { expect, jest, test } from '@jest/globals';
import { CatalogueResultsList } from '../catalogueApi';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

const encoreHeaders = {
  host: [
    { key: 'host', value: 'search.wellcomelibrary.org' }
  ],
  'cloudfront-forwarded-proto': [
    { key: 'cloudfront-forwarded-proto', value: 'https' },
  ],
};

type Test = {
  path: string;
  qs?: string;
  results?: CatalogueResultsList;
  resolvedUri: string;
};
const encoreTests = [
  [
    'root URL',
    {
      path: '',
      resolvedUri: 'https://wellcomecollection.org/collections/',
    },
  ],
  [
    'single record page',
    {
      path: '/iii/encore/record/C__Rb2475299',
      results: results([
        resultWithIdentifier('tsayk6g3', 'sierra-identifier', '2475299'),
      ]),
      resolvedUri: 'https://wellcomecollection.org/works/tsayk6g3'
    },
  ],
  [
    'single record page (with check digit on the Sierra ID in the catalogue API)',
    {
      path: '/iii/encore/record/C__Rb2475299',
      results: results([
        resultWithIdentifier('tsayk6g3', 'sierra-system-number', 'b2475299x'),
      ]),
      resolvedUri: 'https://wellcomecollection.org/works/tsayk6g3'
    },
  ],
  [
    'single record page with language in query string',
    {
      path: '/iii/encore/record/C__Rb3185463',
      qs: 'lang=eng',
      results: results([
        resultWithIdentifier('jg6dqsx4', 'sierra-identifier', '3185463'),
      ]),
      resolvedUri: 'https://wellcomecollection.org/works/jg6dqsx4'
    }
  ],
  [
    'single record page with extra information in the path',
    {
      path: '/iii/encore/record/C__Rb3153458__Sdrugscope__P0%2C1__Orightresult__U__X7',
      qs: 'lang=eng&suite=cobalt',
      results: results([
        resultWithIdentifier('psspw62x', 'sierra-identifier', '3153458'),
      ]),
      resolvedUri: 'https://wellcomecollection.org/works/psspw62x'
    }
  ],
  [
    'account page',
    {
      path: '/iii/encore/myaccount',
      qs: 'lang=eng&suite=cobalt',
      resolvedUri: 'https://wellcomecollection.org/account'
    }
  ],
  [
    'search page with search terms in the query parameters',
    {
      path: '/iii/encore/search',
      qs: 'target=erythromelalgia&submit=Search',
      resolvedUri: 'https://wellcomecollection.org/works?query=erythromelalgia',
    }
  ],
  [
    'search page with search terms in the path',
    {
      path: '/iii/encore/search/C__Srosalind%20paget',
      resolvedUri: 'https://wellcomecollection.org/works?query=rosalind%20paget'
    }
  ],
] as [string, Test][];

test.each(encoreTests)('%s', (name: string, test: Test) => {
  const request = testRequest(test.path, test.qs ?? '', encoreHeaders);

  test.results && mockedAxios.get.mockResolvedValue({
    data: test.results,
  });

  const resultPromise = origin.requestHandler(request, {} as Context);
  return expect(resultPromise).resolves.toEqual(
    expectedRedirect(test.resolvedUri)
  );
});

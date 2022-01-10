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
  qs: string;
  results: CatalogueResultsList;
  resolvedUri: string;
};
const encoreTests = [
  [
    'root URL',
    {
      path: '',
      qs: '',
      results: results([]),
      resolvedUri: 'https://wellcomecollection.org/collections/',
    },
  ],
  [
    'single search page',
    {
      path: '/iii/encore/record/C__Rb2475299',
      qs: '',
      results: results([
        resultWithIdentifier('tsayk6g3', 'sierra-identifier', '2475299'),
      ]),
      resolvedUri: 'https://wellcomecollection.org/works/tsayk6g3'
    },
  ],
  [
    'single search page (with check digit on the Sierra ID)',
    {
      path: '/iii/encore/record/C__Rb2475299',
      qs: '',
      results: results([
        resultWithIdentifier('tsayk6g3', 'sierra-system-number', 'b2475299x'),
      ]),
      resolvedUri: 'https://wellcomecollection.org/works/tsayk6g3'
    },
  ],
  [
    'Encore URL with language query string',
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
    'Longer Encore paths',
    {
      path: '/iii/encore/record/C__Rb3153458__Sdrugscope__P0%2C1__Orightresult__U__X7',
      qs: 'lang=eng&suite=cobalt',
      results: results([
        resultWithIdentifier('psspw62x', 'sierra-identifier', '3153458'),
      ]),
      resolvedUri: 'https://wellcomecollection.org/works/psspw62x'
    }
  ],
] as [string, Test][];

test.each(encoreTests)('%s', (name: string, test: Test) => {
  const request = testRequest(test.path, test.qs, encoreHeaders);
  mockedAxios.get.mockResolvedValue({
    data: test.results,
  });

  const resultPromise = origin.requestHandler(request, {} as Context);
  return expect(resultPromise).resolves.toEqual(
    expectedRedirect(test.resolvedUri)
  );
});

import * as origin from './wellcomeLibraryArchiveRedirect';
import testRequest from './testEventRequest';
import { Context } from 'aws-lambda';
import { results, resultWithIdentifier } from './catalogueApiFixtures';
import { expectedRedirect } from './testHelpers';
import axios from 'axios';
import { afterEach, expect, jest, test } from '@jest/globals';
import { CatalogueResultsList } from './catalogueApi';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

const archivedHeaders = {
  host: [{ key: 'host', value: 'archives.wellcomelibrary.org' }],
  'cloudfront-forwarded-proto': [
    { key: 'cloudfront-forwarded-proto', value: 'https' },
  ],
};

type Test = {
  label: string;
  qs: string;
  results: CatalogueResultsList;
  resolvedUri: string;
};
const archiveTests = [
  {
    label: 'known RefNo in dsqItem',
    qs:
      'dsqIni=Dserve.ini&dsqApp=Archive&dsqDb=Catalog&dsqCmd=NaviTree.tcl&dsqField=RefNo&dsqItem=PPMEL/C',
    results: results([
      resultWithIdentifier('cbms2pg6', 'calm-ref-no', 'PPMEL/C'),
      resultWithIdentifier('refd2pg6', 'calm-ref-no', 'REFNOT'),
    ]),
    resolvedUri: 'https://wellcomecollection.org/works/cbms2pg6',
  },
  {
    label: 'known RefNo in dsqSearch',
    qs:
      'dsqIni=Dserve.ini&dsqApp=Archive&dsqDb=Catalog&dsqCmd=show.tcl&dsqSearch=(RefNo==%27PPADA%27)',
    results: results([
      resultWithIdentifier('jwj9b483', 'calm-ref-no', 'PPADA'),
      resultWithIdentifier('refd2pg6', 'calm-ref-no', 'REFNOT'),
    ]),
    resolvedUri: 'https://wellcomecollection.org/works/jwj9b483',
  },
  {
    label: 'known AltRefNo in dsqSeaarch',
    qs:
      'dsqIni=Dserve.ini&dsqApp=Archive&dsqCmd=Show.tcl&dsqDb=Catalog&dsqPos=0&dsqSearch=(AltRefNo=%27sa/whl%27)',
    results: results([
      resultWithIdentifier('fjg4s86y', 'calm-alt-ref-no', 'SA/WHL'),
      resultWithIdentifier('mtgtt57a', 'calm-alt-ref-no', 'SA/WHL/14'),
    ]),
    resolvedUri: 'https://wellcomecollection.org/works/fjg4s86y',
  },
  {
    label: 'Unknown text in dsqSearch',
    qs:
      'dsqIni=Dserve.ini&dsqApp=Archive&dsqCmd=Show.tcl&dsqDb=Catalog&dsqPos=2&dsqSearch=%28%28%28text%29%3D%27wa%2Fhmm%27%29AND%28%28text%29%3D%27durham%27%29%29',
    results: results([
      resultWithIdentifier('k2fae5cz', 'calm-ref-no', 'WA/HMM'),
      resultWithIdentifier('dr6uy6dg', 'calm-ref-no', 'WA/HSW'),
    ]),
    resolvedUri: 'https://wellcomecollection.org/works?query=wa/hmm%20durham',
  },
  {
    label: 'Unknown AltRefNo in dsqSearch',
    qs:
      'dsqIni=Dserve.ini&dsqApp=Archive&dsqCmd=Show.tcl&dsqDb=Catalog&dsqPos=0&dsqSearch=((AltRefNo=%27MS%27)AND(AltRefNo=%27542%27))',
    results: results([
      resultWithIdentifier('k2fae5cz', 'calm-ref-no', 'MS.542'),
      resultWithIdentifier('dr6uy6dg', 'calm-ref-no', 'MS.345'),
    ]),
    resolvedUri: 'https://wellcomecollection.org/works?query=MS%20542',
  },
] as Test[];

test.each(archiveTests)('$label', (test: Test) => {
  const request = testRequest('/DServe/dserve.exe', test.qs, archivedHeaders);
  mockedAxios.get.mockResolvedValueOnce({
    data: test.results,
  });

  const resultPromise = origin.requestHandler(request, {} as Context);
  return expect(resultPromise).resolves.toEqual(
    expectedRedirect(test.resolvedUri)
  );
});

afterEach(() => {
  jest.resetAllMocks();
});

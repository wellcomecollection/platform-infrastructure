import axios from 'axios';
import { jest, test, expect, afterEach } from '@jest/globals';
import {
  testDataMultiPageFirstPage,
  testDataMultiPageNextPage,
  testDataNoResults,
  testDataSingleResult,
} from './catalogueApiFixtures';
import { Work, CatalogueResultsList, Identifier } from '../catalogueApi';
import { getWork } from '../bnumberToWork';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

const includesSierraId = [
  {
    identifierType: {
      id: 'sierra-identifier',
      label: 'Sierra identifier',
      type: 'IdentifierType',
    },
    value: '1206278',
    type: 'Identifier',
  } as Identifier,
];

const includesSierraSysNum = [
  {
    identifierType: {
      id: 'sierra-system-number',
      label: 'Sierra system number',
      type: 'IdentifierType',
    },
    value: 'b12062789',
    type: 'Identifier',
  } as Identifier,
];

const excludesSierraIdentifiers = [
  {
    identifierType: {
      id: 'regular-lottery-ticket',
      label: 'Regular lottery numbers',
      type: 'IdentifierType',
    },
    value: '1234567890',
    type: 'Identifier',
  } as Identifier,
];

function addIdentifiersToPage(
  identifiers: Identifier[],
  resultList: CatalogueResultsList
) {
  return {
    ...resultList,
    results: [
      {
        ...resultList.results[0],
        identifiers: identifiers,
      },
    ],
  };
}

test('returns an Error when none available', async () => {
  mockedAxios.get
    .mockResolvedValueOnce({ data: testDataNoResults })
    .mockResolvedValueOnce({ data: testDataNoResults });

  const workResults = await getWork({
    sierraIdentifier: '1234567',
    sierraSystemNumber: 'b1234567x',
  });

  expect(workResults).toEqual(Error('No matching Catalogue API results found'));
});

test('returns the work with a "sierra-identifier" identifier', async () => {
  const firstPageWithSierraIdentifiers = addIdentifiersToPage(
    includesSierraId,
    testDataMultiPageFirstPage as CatalogueResultsList
  );
  const nextPageWithoutSierraIdentifiers = addIdentifiersToPage(
    excludesSierraIdentifiers,
    testDataMultiPageNextPage as CatalogueResultsList
  );

  mockedAxios.get
    .mockResolvedValueOnce({ data: firstPageWithSierraIdentifiers })
    .mockResolvedValueOnce({ data: nextPageWithoutSierraIdentifiers });

  const expectedWork = firstPageWithSierraIdentifiers.results[0] as Work;

  const workResults = await getWork({
    sierraIdentifier: includesSierraId[0].value,
    sierraSystemNumber: 'b12062789',
  });

  expect(workResults).toEqual(expectedWork);
});

test('returns the work with a "sierra-system-number" identifier when no "sierra-identifier"', async () => {
  const firstRequestWithOutSierraIdentifiers = addIdentifiersToPage(
    excludesSierraIdentifiers,
    testDataSingleResult as CatalogueResultsList
  );
  const nextRequestWithSierraSysNumIdentifiers = addIdentifiersToPage(
    includesSierraSysNum,
    testDataSingleResult as CatalogueResultsList
  );

  mockedAxios.get
    .mockResolvedValueOnce({ data: firstRequestWithOutSierraIdentifiers })
    .mockResolvedValueOnce({ data: nextRequestWithSierraSysNumIdentifiers });

  const expectedWork = nextRequestWithSierraSysNumIdentifiers
    .results[0] as Work;

  const workResults = await getWork({
    sierraIdentifier: 'nope',
    sierraSystemNumber: includesSierraSysNum[0].value,
  });

  expect(workResults).toEqual(expectedWork);
});

afterEach(() => {
  jest.resetAllMocks();
});

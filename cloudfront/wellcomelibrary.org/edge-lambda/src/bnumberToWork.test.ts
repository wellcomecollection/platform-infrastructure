import axios from 'axios';
import { jest, test, expect } from '@jest/globals';
import {
  testDataMultiPageFirstPage,
  testDataMultiPageNextPage,
  testDataNoResults,
  testDataSingleResult,
} from './apiFixtures';
import { Work, CatalogueResultsList, Identifier } from './api';
import { getWork } from './bnumberToWork';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

test('returns an Error when none available', async () => {
  mockedAxios.get.mockResolvedValueOnce({ data: testDataNoResults });

  const workResults = await getWork('bnumber');
  expect(workResults).toEqual(Error('No matching Catalogue API results found'));
});

test('returns a Work when one result available', async () => {
  mockedAxios.get.mockResolvedValueOnce({ data: testDataSingleResult });

  const expectedWork = testDataSingleResult.results[0] as Work;

  const workResults = await getWork('bnumber');
  expect(workResults).toEqual(expectedWork);
});

const includesSierraIdentifiers = [
  {
    identifierType: {
      id: 'sierra-system-number',
      label: 'Sierra system number',
      type: 'IdentifierType',
    },
    value: 'b12062789',
    type: 'Identifier',
  } as Identifier,

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
  const firstResult = resultList.results[0];
  const resultWithIdentifiers = Object.assign(firstResult, {
    identifiers: identifiers,
  });
  return Object.assign(resultList, { results: [resultWithIdentifiers] });
}

test('returns the last work when no identifiers', async () => {
  const firstPageWithoutSierraIdentifiers = addIdentifiersToPage(
    excludesSierraIdentifiers,
    testDataMultiPageFirstPage as CatalogueResultsList
  );
  const nextPageWithoutSierraIdentifiers = addIdentifiersToPage(
    excludesSierraIdentifiers,
    testDataMultiPageNextPage as CatalogueResultsList
  );

  mockedAxios.get
    .mockResolvedValueOnce({ data: firstPageWithoutSierraIdentifiers })
    .mockResolvedValueOnce({ data: nextPageWithoutSierraIdentifiers });

  const expectedWork = nextPageWithoutSierraIdentifiers.results[0] as Work;

  const workResults = await getWork('bnumber');
  expect(workResults).toEqual(expectedWork);
});

test('returns the first Work with a "sierra-identifier" identifier', async () => {
  const firstPageWithSierraIdentifiers = addIdentifiersToPage(
    includesSierraIdentifiers,
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

  const workResults = await getWork('bnumber');
  expect(workResults).toEqual(expectedWork);
});

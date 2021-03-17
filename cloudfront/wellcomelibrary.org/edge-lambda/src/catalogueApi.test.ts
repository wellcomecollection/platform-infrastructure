import axios from 'axios';
import { jest, test, expect } from '@jest/globals';

import { apiQuery, Work } from './catalogueApi';
import {
  testDataMultiPageFirstPage,
  testDataMultiPageNextPage,
  testDataMultipleResults,
  testDataNoResults,
  testDataSingleResult,
} from './catalogueApiFixtures';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

test('returns no results when none available', async () => {
  mockedAxios.get.mockResolvedValueOnce({ data: testDataNoResults });

  const resultList = apiQuery({
    query: 'bnumber',
    include: ['identifiers'],
  });

  const works = [];

  for await (const result of resultList) {
    works.push(result);
  }

  expect(works).toEqual([]);
});

test('returns a result when one available', async () => {
  mockedAxios.get.mockResolvedValueOnce({ data: testDataSingleResult });

  const resultList = apiQuery({
    query: 'bnumber',
    include: ['identifiers'],
  });

  const works = [];

  for await (const result of resultList) {
    works.push(result);
  }

  expect(works).toEqual([testDataSingleResult.results[0] as Work]);
});

test('returns multiple result when available', async () => {
  mockedAxios.get.mockResolvedValueOnce({ data: testDataMultipleResults });

  const resultList = apiQuery({
    query: 'bnumber',
    include: ['identifiers'],
  });

  const works = [];
  for await (const result of resultList) {
    works.push(result);
  }

  const expectedResults = [];
  for await (const result of testDataMultipleResults.results) {
    expectedResults.push(result as Work);
  }

  expect(works).toEqual(expectedResults);
});

test('returns multiple result across pages', async () => {
  mockedAxios.get
    .mockResolvedValueOnce({ data: testDataMultiPageFirstPage })
    .mockResolvedValueOnce({ data: testDataMultiPageNextPage });

  const resultList = apiQuery({
    query: 'bnumber',
    include: ['identifiers'],
  });

  const works = [];
  for await (const result of resultList) {
    works.push(result);
  }

  const expectedResults = [
    testDataMultiPageFirstPage.results[0] as Work,
    testDataMultiPageNextPage.results[0] as Work,
  ];

  expect(works).toEqual(expectedResults);
});

import { expect, test, jest, afterEach } from '@jest/globals';
import axios from 'axios';
import { safeGet } from '../safeGet';

import { axios404, axiosNoResponse } from './testHelpers';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

test('returns an error when a non-success status error is thrown', async () => {
  mockedAxios.get.mockImplementation(async () => {
    return Promise.reject(axios404);
  });

  const getResult = await safeGet('http://www.example.com');
  const expectedError = Error('Got 404 from http://www.example.com');

  expect(getResult).toEqual(expectedError);
});

test('returns an error when a no-response error is thrown', async () => {
  mockedAxios.get.mockImplementation(async () => {
    return Promise.reject(axiosNoResponse);
  });

  const getResult = await safeGet('http://www.example.com');
  const expectedError = Error('No response from http://www.example.com');

  expect(getResult).toEqual(expectedError);
});

test('returns an error when an unexpected error is thrown', async () => {
  const expectedUnexpectedError = Error('The spanish inquisition!');
  const expectedError = Error(
    `Unknown error from http://www.example.com: ${expectedUnexpectedError}`
  );

  mockedAxios.get.mockImplementation(async () => {
    return Promise.reject(expectedUnexpectedError);
  });

  const getResult = await safeGet('http://www.example.com');

  expect(getResult).toEqual(expectedError);
});

test('returns the data value with a success response', async () => {
  const expectedData = 'expected_data';
  mockedAxios.get.mockResolvedValueOnce({ data: expectedData });

  const getResult = await safeGet('http://www.example.com');

  expect(getResult).toEqual(expectedData);
});

afterEach(() => {
  jest.resetAllMocks();
});

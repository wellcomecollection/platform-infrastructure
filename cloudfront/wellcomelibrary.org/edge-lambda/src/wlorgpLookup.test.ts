import { expect, test, jest, afterEach } from '@jest/globals';
import { safeGet } from './safeGet';

import { wlorgpLookup } from './wlorgpLookup';
import { AxiosRequestConfig } from 'axios';

jest.mock('./safeGet');
const safeGetMock = safeGet as jest.MockedFunction<
  (url: string, config?: AxiosRequestConfig) => Promise<Error | string>
>;

test('returns an error from safeGet', async () => {
  const expectedError = Error('nope');
  safeGetMock.mockResolvedValueOnce(expectedError);

  const lookupResult = await wlorgpLookup('http://www.example.com');

  expect(lookupResult).toEqual(expectedError);
});

test('returns an error if an invalid URL is returned', async () => {
  const invalidUrl = 'invalid-url';
  const expectedError = Error(`Invalid URL: ${invalidUrl}`);

  safeGetMock.mockResolvedValueOnce(invalidUrl);

  const lookupResult = await wlorgpLookup('http://www.example.com');

  expect(lookupResult).toEqual(expectedError);
});

test('returns a URL if valid is returned', async () => {
  const validUrl = 'http://www.example.com/some/page?query=pengvin&botmin';

  safeGetMock.mockResolvedValueOnce(validUrl);

  const lookupResult = await wlorgpLookup('http://www.example.com');

  expect(lookupResult).toEqual(new URL(validUrl));
});

afterEach(() => {
  jest.resetAllMocks();
});

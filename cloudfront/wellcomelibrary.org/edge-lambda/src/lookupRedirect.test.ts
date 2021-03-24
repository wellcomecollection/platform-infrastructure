import { expect, test } from '@jest/globals';
import { lookupRedirect } from './lookupRedirect';
import { CloudFrontResultResponse } from 'aws-lambda';

test('returns a valid redirect', async () => {
  const lookupResult = lookupRedirect(
    { '/foo': 'http://www.example.com/bar' },
    '/foo'
  );

  const expectedRedirect = {
    headers: {
      location: [{ key: 'Location', value: 'http://www.example.com/bar' }],
    },
    status: '302',
    statusDescription: 'Redirecting to http://www.example.com/bar',
  } as CloudFrontResultResponse;

  // Temporary redirect should be updated to permanent when redirections are stable
  expect(lookupResult).toStrictEqual(expectedRedirect);
});

test('strips trailing slashes', async () => {
  const lookupResult: CloudFrontResultResponse | undefined = lookupRedirect(
    { '/foo': 'http://www.example.com/bar' },
    '/foo/'
  );

  const expectedRedirect = {
    headers: {
      location: [{ key: 'Location', value: 'http://www.example.com/bar' }],
    },
    status: '302',
    statusDescription: 'Redirecting to http://www.example.com/bar',
  } as CloudFrontResultResponse;

  // Temporary redirect should be updated to permanent when redirections are stable
  expect(lookupResult).toStrictEqual(expectedRedirect);
});

test('returns undefined when no redirect available', async () => {
  const lookupResult = lookupRedirect(
    { '/foo': 'http://www.example.com/bar' },
    '/baz'
  );

  // Temporary redirect should be updated to permanent when redirections are stable
  expect(lookupResult).toBe(undefined);
});

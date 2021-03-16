import { expect, test } from '@jest/globals';
import { lookupStaticRedirect } from './lookupStaticRedirect';
import { CloudFrontResultResponse } from 'aws-lambda';

test('returns a valid redirect', async () => {
  const lookupResult = lookupStaticRedirect({ '/foo': '/bar' }, '/foo');

  const expectedRedirect = {
    headers: { location: [{ key: 'Location', value: '/bar' }] },
    status: '302',
    statusDescription: 'Redirecting to /bar',
  } as CloudFrontResultResponse;

  // Temporary redirect should be updated to permanent when redirections are stable
  expect(lookupResult).toStrictEqual(expectedRedirect);
});

test('strips trialing slashes', async () => {
  const lookupResult:
    | CloudFrontResultResponse
    | undefined = lookupStaticRedirect({ '/foo': '/bar' }, '/foo/');

  const expectedRedirect = {
    headers: { location: [{ key: 'Location', value: '/bar' }] },
    status: '302',
    statusDescription: 'Redirecting to /bar',
  } as CloudFrontResultResponse;

  // Temporary redirect should be updated to permanent when redirections are stable
  expect(lookupResult).toStrictEqual(expectedRedirect);
});

test('returns undefined when no redirect available', async () => {
  const lookupResult = lookupStaticRedirect({ '/foo': '/bar' }, '/baz');

  // Temporary redirect should be updated to permanent when redirections are stable
  expect(lookupResult).toBe(undefined);
});

import { expect, test } from '@jest/globals';
import { redirectToRoot } from './redirectToRoot';
import { createCloudFrontRequest } from './testEventRequest';
import { expectedRedirect } from './testHelpers';

test('http requests are redirected to https', () => {
  const request = createCloudFrontRequest('/foo', undefined, {
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
    'cloudfront-forwarded-proto': [
      { key: 'cloudfront-forwarded-proto', value: 'http' },
    ],
  });

  const redirectResult = redirectToRoot(request);

  expect(redirectResult).toEqual(
    expectedRedirect('https://wellcomelibrary.org/foo')
  );
});

test('redirects www. to root', () => {
  const request = createCloudFrontRequest('/foo', undefined, {
    host: [{ key: 'host', value: 'www.wellcomelibrary.org' }],
    'cloudfront-forwarded-proto': [
      { key: 'cloudfront-forwarded-proto', value: 'https' },
    ],
  });

  const redirectResult = redirectToRoot(request);

  expect(redirectResult).toEqual(
    expectedRedirect('https://wellcomelibrary.org/foo')
  );
});

test('redirects http AND www. to root/https together', () => {
  const request = createCloudFrontRequest('/foo', undefined, {
    host: [{ key: 'host', value: 'www.wellcomelibrary.org' }],
    'cloudfront-forwarded-proto': [
      { key: 'cloudfront-forwarded-proto', value: 'http' },
    ],
  });

  const redirectResult = redirectToRoot(request);

  expect(redirectResult).toEqual(
    expectedRedirect('https://wellcomelibrary.org/foo')
  );
});

test('returns undefined if at root and with https', () => {
  const request = createCloudFrontRequest('/foo', undefined, {
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
    'cloudfront-forwarded-proto': [
      { key: 'cloudfront-forwarded-proto', value: 'https' },
    ],
  });

  const redirectResult = redirectToRoot(request);

  expect(redirectResult).toEqual(undefined);
});

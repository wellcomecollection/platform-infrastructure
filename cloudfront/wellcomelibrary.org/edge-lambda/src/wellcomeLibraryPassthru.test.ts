import { expect, test } from '@jest/globals';
import testRequest from './testEventRequest';
import * as origin from './wellcomeLibraryPassthru';
import { Context } from 'aws-lambda';
import { expectedCORSRedirect } from './testHelpers';

test('redirects www. to root', () => {
  const request = testRequest('/foo', undefined, {
    host: [{ key: 'host', value: 'www.wellcomelibrary.org' }],
    'cloudfront-forwarded-proto': [
      { key: 'cloudfront-forwarded-proto', value: 'https' },
    ],
  });

  const resultPromise = origin.requestHandler(request, {} as Context);

  return expect(resultPromise).resolves.toEqual(
    expectedCORSRedirect('https://wellcomelibrary.org/foo')
  );
});

test('http requests are redirected to https', () => {
  const request = testRequest('/foo', undefined, {
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
    'cloudfront-forwarded-proto': [
      { key: 'cloudfront-forwarded-proto', value: 'http' },
    ],
  });

  const resultPromise = origin.requestHandler(request, {} as Context);

  return expect(resultPromise).resolves.toEqual(
    expectedCORSRedirect('https://wellcomelibrary.org/foo')
  );
});

test('rewrites the host header if it exists', async () => {
  const request = testRequest('/', undefined, {
    host: [{ key: 'host', value: 'www.wellcomelibrary.org' }],
  });

  const originRequest = await origin.requestHandler(request, {} as Context);

  expect(originRequest.headers).toStrictEqual({
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
  });
});

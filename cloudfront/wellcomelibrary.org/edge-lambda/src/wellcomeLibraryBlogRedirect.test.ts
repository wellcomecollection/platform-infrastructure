import { expect, test } from '@jest/globals';
import testRequest from './testEventRequest';
import * as origin from './wellcomeLibraryBlogRedirect';
import { Context } from 'aws-lambda';
import { expectedRedirect, expectedServerError } from './testHelpers';
import { blogHost, waybackPrefix } from './wellcomeLibraryBlogRedirect';

test('redirects blog. to the wayback machine', () => {
  const expectedPath = '/foo';
  const request = testRequest(expectedPath, undefined, {
    host: [{ key: 'host', value: 'blog.wellcomelibrary.org' }],
  });

  const resultPromise = origin.requestHandler(request, {} as Context);

  // Ensure we're redirecting to the wayback machine!
  expect(
    waybackPrefix.startsWith('https://wayback.archive-it.org/')
  ).toBeTruthy();

  return expect(resultPromise).resolves.toEqual(
    expectedRedirect(
      `${waybackPrefix}https://blog.wellcomelibrary.org${expectedPath}`
    )
  );
});

test('errors if no host header', () => {
  const expectedPath = '/foo';
  const request = testRequest(expectedPath, undefined, {});

  const resultPromise = origin.requestHandler(request, {} as Context);

  return expect(resultPromise).resolves.toEqual(
    expectedServerError(
      `No host header found: Trying to redirect ${blogHost}${expectedPath}`
    )
  );
});

test('errors if host header has incorrect value', () => {
  const expectedPath = '/foo';
  const badHost = 'catalogue.wellcomelibrary.org';
  const request = testRequest(expectedPath, undefined, {
    host: [{ key: 'host', value: 'catalogue.wellcomelibrary.org' }],
  });
  const resultPromise = origin.requestHandler(request, {} as Context);

  return expect(resultPromise).resolves.toEqual(
    expectedServerError(
      `Host header ${badHost} does not start with 'blog.': Trying to redirect ${blogHost}${expectedPath}`
    )
  );
});

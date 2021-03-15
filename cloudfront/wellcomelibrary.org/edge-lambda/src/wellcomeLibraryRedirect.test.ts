import * as origin from './wellcomeLibraryRedirect';
import testRequest from './testEventRequest';
import { Context } from 'aws-lambda';
import { testDataNoResults, testDataSingleResult } from './apiFixtures';
import { expectedPassthru, expectedRedirect } from './testHelpers';
import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';
import axios from 'axios';
import { expect, jest, test } from '@jest/globals';
import {readStaticRedirects} from "./staticRedirects";

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

test('redirects www. to root', () => {
  const request = testRequest('/foo', undefined, {
    host: [{ key: 'host', value: 'www.wellcomelibrary.org' }],
  });

  const resultPromise = origin.requestHandler(request, {} as Context);

  return expect(resultPromise).resolves.toEqual(
    expectedRedirect('https://wellcomelibrary.org/foo')
  );
});

type ExpectedRewrite = {
  in: string;
  out: CloudFrontResultResponse | CloudFrontRequest;
  data?: any;
};

const rewriteTests = (): ExpectedRewrite[] => {
  return [
    // Item page tests
    {
      in: '/item/b21293302',
      out: expectedRedirect('https://wellcomecollection.org/works/k2a8y7q6'),
      data: testDataSingleResult,
    },
    {
      in: '/item/b21293302',
      out: expectedRedirect('https://wellcomecollection.org/works/not-found'),
      data: testDataNoResults,
    },
    {
      in: '/item/not-bnumber',
      out: expectedRedirect('https://wellcomecollection.org/works/not-found'),
    },
    {
      in: '/not-item',
      out: expectedPassthru('/not-item'),
    },
    // Events pages redirect
    {
      in: '/events',
      out: expectedRedirect('https://wellcomecollection.org/whats-on'),
    },
    {
      in: '/events/any-thing',
      out: expectedRedirect('https://wellcomecollection.org/whats-on'),
    },
    // Static redirects
    // TODO: Optional trailing slash!
    // TODO: Decide which examples to test (all?)
    {
      in: '/using-the-library/',
      out: expectedRedirect('https://wellcomecollection.org/pages/Wuw19yIAAK1Z3Smm'),
    },
  ];
};

test.each(rewriteTests())(
  'Request path is rewritten: %o',
  async (expected: ExpectedRewrite) => {
    const request = testRequest(expected.in);

    if (expected.data) {
      mockedAxios.get.mockResolvedValueOnce({ data: expected.data });
    }

    const originRequest = await origin.requestHandler(request, {} as Context);

    expect(originRequest).toStrictEqual(expected.out);
  }
);

test('rewrites the host header if it exists', async () => {
  const request = testRequest('/', undefined, {
    host: [{ key: 'host', value: 'notwellcomelibrary.org' }],
  });

  const originRequest = await origin.requestHandler(request, {} as Context);

  expect(originRequest.headers).toStrictEqual({
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
  });
});

test('adds the host header if it is missing', async () => {
  const request = testRequest('/', undefined);

  const originRequest = await origin.requestHandler(request, {} as Context);

  expect(originRequest.headers).toStrictEqual({
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
  });
});

test('leaves other headers unmodified', async () => {
  const request = testRequest('/', undefined, {
    host: [{ key: 'host', value: 'notwellcomelibrary.org' }],
    connection: [{ key: 'connection', value: 'close' }],
    authorization: [
      { key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l' },
    ],
  });

  const originRequest = await origin.requestHandler(request, {} as Context);

  expect(originRequest.headers).toStrictEqual({
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
    connection: [{ key: 'connection', value: 'close' }],
    authorization: [
      { key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l' },
    ],
  });
});

// test('flarp', async () => {
//   const foo = await readStaticRedirects()
//
//   expect(foo).toBe(true)
// });
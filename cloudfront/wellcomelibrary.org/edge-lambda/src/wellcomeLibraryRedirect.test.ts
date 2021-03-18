import * as origin from './wellcomeLibraryRedirect';
import testRequest from './testEventRequest';
import { Context } from 'aws-lambda';
import {
  testDataNoResults,
  testDataSingleResult,
} from './catalogueApiFixtures';
import {
  axios404,
  axiosNoResponse,
  expectedCORSRedirect,
  expectedPassthru,
  expectedRedirect,
  expectedServerError,
} from './testHelpers';
import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';
import axios from 'axios';
import { expect, jest, test } from '@jest/globals';

import rawStaticRedirects from './staticRedirects.json';
const staticRedirects = rawStaticRedirects as Record<string, string>;

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
  error?: Error;
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
    // Static redirects (complementary to staticRedirectTests)
    {
      in: '/using-the-library/',
      out: expectedRedirect(
        'https://wellcomecollection.org/pages/Wuw19yIAAK1Z3Smm'
      ),
    },
    {
      in: '/using-the-library',
      out: expectedRedirect(
        'https://wellcomecollection.org/pages/Wuw19yIAAK1Z3Smm'
      ),
    },
    // API uris redirect
    {
      in: '/iiif/collection/happy-path',
      out: expectedCORSRedirect(
        'https://iiif.wellcomecollection.org/presentation/v2/happy-path'
      ),
      data: 'https://iiif.wellcomecollection.org/presentation/v2/happy-path',
    },
    {
      in: '/iiif/collection/not-found',
      out: expectedServerError(
        'Got 404 from https://iiif.wellcomecollection.org/wlorgp/iiif/collection/not-found'
      ),
      error: axios404,
    },
    {
      in: '/iiif/collection/no-response',
      out: expectedServerError(
        'No response from https://iiif.wellcomecollection.org/wlorgp/iiif/collection/no-response'
      ),
      error: axiosNoResponse,
    },
    {
      in: '/iiif/collection/error',
      out: expectedServerError(
        'Unknown error from https://iiif.wellcomecollection.org/wlorgp/iiif/collection/error: Error: nope'
      ),
      error: Error('nope'),
    },
    {
      in: '/iiif/collection/invalid-url',
      out: expectedServerError('Invalid URL: not_a_url'),
      data: 'not_a_url',
    },
    {
      in: '/service/alto/happy-path/0?image=400',
      out: expectedCORSRedirect(
        'https://iiif.wellcomecollection.org/text/alto/happy-path/b28047345_0403.jp2'
      ),
      data:
        'https://iiif.wellcomecollection.org/text/alto/happy-path/b28047345_0403.jp2',
    },
    {
      in: '/ddsconf/happy-path',
      out: expectedCORSRedirect('https://iiif.wellcomecollection.org/bar/bat'),
      data: 'https://iiif.wellcomecollection.org/bar/bat',
    },
    {
      in: '/dds-static/happy-path',
      out: expectedCORSRedirect('https://iiif.wellcomecollection.org/bar/bat'),
      data: 'https://iiif.wellcomecollection.org/bar/bat',
    },
    {
      in: '/annoservices/search/happy-path?q=butterfly',
      out: expectedCORSRedirect('https://iiif.wellcomecollection.org/bar/bat'),
      data: 'https://iiif.wellcomecollection.org/bar/bat',
    },
  ];
};

test.each(rewriteTests())(
  'Request path is rewritten: %o',
  async (expected: ExpectedRewrite) => {
    const request = testRequest(expected.in);

    if (expected.error) {
      mockedAxios.get.mockImplementation(async () => {
        return Promise.reject(expected.error);
      });
    }

    if (expected.data) {
      mockedAxios.get.mockResolvedValueOnce({ data: expected.data });
    }

    const originRequest = await origin.requestHandler(request, {} as Context);

    expect(originRequest).toStrictEqual(expected.out);
  }
);

const staticRedirectTests = Object.entries(staticRedirects).map(
  ([path, redirect]) => {
    return {
      in: path,
      out: expectedRedirect(redirect),
    };
  }
);

test.each(staticRedirectTests)(
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

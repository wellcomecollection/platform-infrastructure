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
    // API uris redirect
    {
      in: '/iiif/collection/b18031900',
      out: expectedCORSRedirect(
        'https://iiif.wellcomecollection.org/presentation/v2/b18031900'
      ),
      data: 'https://iiif.wellcomecollection.org/presentation/v2/b18031900',
    },
    {
      in: '/iiif/collection/b18031900',
      out: expectedServerError(
        'Got 404 from https://iiif.wellcomecollection.org/wlorgp/iiif/collection/b18031900'
      ),
      error: axios404,
    },
    {
      in: '/iiif/collection/b18031900',
      out: expectedServerError(
        'No response from https://iiif.wellcomecollection.org/wlorgp/iiif/collection/b18031900'
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
      in: '/iiif/collection/not-available',
      out: expectedServerError('Invalid URL: not_a_url'),
      data: 'not_a_url',
    },
    {
      in: '/service/alto/b28047345/0?image=400',
      out: expectedCORSRedirect(
        'https://iiif.wellcomecollection.org/text/alto/b28047345/b28047345_0403.jp2'
      ),
      data:
        'https://iiif.wellcomecollection.org/text/alto/b28047345/b28047345_0403.jp2',
    },
    {
      in: '/ddsconf/foo',
      out: expectedCORSRedirect('https://iiif.wellcomecollection.org/bar/bat'),
      data: 'https://iiif.wellcomecollection.org/bar/bat',
    },
    {
      in: '/dds-static/login',
      out: expectedCORSRedirect('https://iiif.wellcomecollection.org/bar/bat'),
      data: 'https://iiif.wellcomecollection.org/bar/bat',
    },
    {
      in: '/annoservices/search/b28047345?q=butterfly',
      out: expectedCORSRedirect('https://iiif.wellcomecollection.org/bar/bat'),
      data: 'https://iiif.wellcomecollection.org/bar/bat',
    }
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

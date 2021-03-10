import * as origin from './wellcomeLibraryRedirect';
import testRequest from './testEventRequest';
import { Context } from 'aws-lambda';
import { testDataNoResults, testDataSingleResult } from './apiFixtures';
import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';
import axios from 'axios';
import { jest, test, expect } from '@jest/globals';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

type ExpectedRewrite = {
  in: string;
  out: CloudFrontResultResponse | CloudFrontRequest;
  data: any;
};

function expectedRedirect(uri: string): CloudFrontResultResponse {
  return {
    status: '302',
    statusDescription: `Redirecting to ${uri}`,
    headers: {
      location: [
        {
          key: 'Location',
          value: uri,
        },
      ],
    },
  } as CloudFrontResultResponse;
}

function expectedPassthru(uri: string): CloudFrontRequest {
  return {
    clientIp: '2001:cdba::3257:9652',
    headers: {
      host: [
        {
          key: 'host',
          value: 'wellcomelibrary.org',
        },
      ],
    },
    method: 'GET',
    querystring: '',
    uri: uri,
  } as CloudFrontRequest;
}

const rewriteTests = (): Array<ExpectedRewrite> => {
  return [
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
      data: {},
    },
    {
      in: '/not-item',
      out: expectedPassthru('/not-item'),
      data: {},
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

test('redirects www. to root', () => {
  const request = testRequest('/foo', undefined, {
    host: [{ key: 'host', value: 'www.wellcomelibrary.org' }],
  });

  const resultPromise = origin.requestHandler(request, {} as Context);

  return expect(resultPromise).resolves.toEqual(
    expectedRedirect('https://wellcomelibrary.org/foo')
  );
});

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

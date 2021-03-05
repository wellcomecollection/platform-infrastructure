import * as origin from './wellcomeLibraryRedirect';
import testRequest from './testEventRequest';
import { Context } from 'aws-lambda';

interface ExpectedRewrite {
  in: string;
  out: string;
}

const rewriteTests = (): Array<ExpectedRewrite> => {
  return [
    {
      in: '/foo/bat',
      out: '/bar/bat',
    },
  ];
};

test.each(rewriteTests())(
  'Request path is rewritten: %o',
  (expected: ExpectedRewrite) => {
    const requestCallback = jest.fn((_, request) => request);
    const r = testRequest(expected.in);

    origin.requestHandler(r, {} as Context, requestCallback);

    expect(r.Records[0].cf.request.uri).toBe(expected.out);
  }
);

test(`rewrites the host header if it exists`, () => {
    const requestCallback = jest.fn((_, request) => request);
    const request = testRequest('/', undefined, {
        host: [{ key: 'host', value: 'notwellcomelibrary.org' }],
    });

    origin.requestHandler(request, {} as Context, requestCallback);

    expect(request.Records[0].cf.request.headers).toStrictEqual({
        host: [{ key: 'host', value: 'wellcomelibrary.org' }],
    });
});

test(`adds the host header if it is missing`, () => {
    const requestCallback = jest.fn((_, request) => request);
    const request = testRequest('/', undefined);

    origin.requestHandler(request, {} as Context, requestCallback);

    expect(request.Records[0].cf.request.headers).toStrictEqual({
        host: [{ key: 'host', value: 'wellcomelibrary.org' }],
    });
});

test(`leaves other headers unmodified`, () => {
    const requestCallback = jest.fn((_, request) => request);
    const request = testRequest('/', undefined, {
        host: [{ key: 'host', value: 'notwellcomelibrary.org' }],
        connection: [{ key: 'connection', value: 'close' }],
        authorization: [
            { key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l' },
        ],
    });

    origin.requestHandler(request, {} as Context, requestCallback);

    expect(request.Records[0].cf.request.headers).toStrictEqual({
        host: [{ key: 'host', value: 'wellcomelibrary.org' }],
        connection: [{ key: 'connection', value: 'close' }],
        authorization: [
            { key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l' },
        ],
    });
});

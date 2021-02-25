import { CloudFrontRequestHandler, Context } from 'aws-lambda';
import { requestHandler } from './hostHijacker';
import testEventRequest from './testEventRequest';

test(`rewrites the host header if it exists`, () => {
  const callback = jest.fn((_, request) => request);
  const request = testEventRequest('/', undefined, {
    host: [{ key: 'host', value: 'notwellcomelibrary.org' }],
  });

  requestHandler(request, {} as Context, callback);

  expect(request.Records[0].cf.request.headers).toStrictEqual({
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
  });
});

test(`adds the host header if it is missing`, () => {
  const callback = jest.fn((_, request) => request);
  const request = testEventRequest('/', undefined);

  requestHandler(request, {} as Context, callback);

  expect(request.Records[0].cf.request.headers).toStrictEqual({
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
  });
});

test(`leaves other headers unmodified`, () => {
  const callback = jest.fn((_, request) => request);
  const request = testEventRequest('/', undefined, {
    host: [{ key: 'host', value: 'notwellcomelibrary.org' }],
    connection: [{ key: 'connection', value: 'close' }],
    authorization: [
      { key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l' },
    ],
  });

  requestHandler(request, {} as Context, callback);

  expect(request.Records[0].cf.request.headers).toStrictEqual({
    host: [{ key: 'host', value: 'wellcomelibrary.org' }],
    connection: [{ key: 'connection', value: 'close' }],
    authorization: [
      { key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l' },
    ],
  });
});

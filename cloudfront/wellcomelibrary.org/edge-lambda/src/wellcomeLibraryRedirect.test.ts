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

    origin.request(r, {} as Context, requestCallback);

    expect(r.Records[0].cf.request.uri).toBe(expected.out);
  }
);

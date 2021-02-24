import * as origin from './wellcome_library_redirect';
import testRequest from './test_event_request';
import { Context } from 'aws-lambda';

interface ExpectedRewrite {
  in: string
  out: string
}

const rewrite_tests = (): Array<ExpectedRewrite> => {
  return [
    {
      in: '/foo/bat',
      out: '/bar/bat'
    }
  ]
}

test.each(rewrite_tests())(
    'Request path is rewritten: %o',
    (expected:ExpectedRewrite) => {
      const requestCallback = jest.fn((_, request) => request);
      const r = testRequest(expected.in)

      origin.request(r, {} as Context, requestCallback);

      expect(r.Records[0].cf.request.uri).toBe(expected.out);
    }
);

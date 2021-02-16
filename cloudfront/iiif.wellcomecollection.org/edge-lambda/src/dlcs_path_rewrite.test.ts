import * as origin from './dlcs_path_rewrite';
import testRequest from './test_event_request';
import { Context } from 'aws-lambda';

interface ExpectedRewrite {
  in: string
  out: string
}

const rewrite_tests = (): Array<ExpectedRewrite> => {
  return [
    // Loris style paths including .jpg extension
    {
      in: '/image/A00123456.jpg/full/1338%2C/0/default.jpg',
      out: '/A00123456/full/1338%2C/0/default.jpg'
    },
    {
      in: '/image/B00123456.jpg/full/1338%2C/0/default.jpg',
      out: '/B00123456/full/1338%2C/0/default.jpg'
    },
    {
      in: '/image/L00123456.jpg/full/1338%2C/0/default.jpg',
      out: '/L00123456/full/1338%2C/0/default.jpg'
    },
    {
      in: '/image/M00123456.jpg/full/1338%2C/0/default.jpg',
      out: '/M00123456/full/1338%2C/0/default.jpg'
    },
    {
      in: '/image/N00123456.jpg/full/1338%2C/0/default.jpg',
      out: '/N00123456/full/1338%2C/0/default.jpg'
    },
    {
      in: '/image/S00123456.jpg/full/1338%2C/0/default.jpg',
      out: '/S00123456/full/1338%2C/0/default.jpg'
    },
    {
      in: '/image/V00123456.jpg/full/1338%2C/0/default.jpg',
      out: '/V00123456/full/1338%2C/0/default.jpg'
    },
    {
      in: '/image/W00123456.jpg/full/1338%2C/0/default.jpg',
      out: '/W00123456/full/1338%2C/0/default.jpg'
    },
    // Paths excluding .jpg extension
    {
      in: '/image/B0009853/full/1338%2C/0/default.jpg',
      out: '/B0009853/full/1338%2C/0/default.jpg'
    },
    {
      in: '/image/B0009853/full/1338%2C/0/default.png',
      out: '/B0009853/full/1338%2C/0/default.png'
    },
    {
      in: '/image/B0009853/full/1338%2C/0/gray.jpg',
      out: '/B0009853/full/1338%2C/0/gray.jpg'
    },
    {
      in: '/image/B0009853/400%2C400%2C200%2C200/1338%2C/0/default.jpg',
      out: '/B0009853/400%2C400%2C200%2C200/1338%2C/0/default.jpg'
    },
    // DLCS image paths not in the Wellcome Images set
    {
      in: '/image/B28573286.JP2/full/1338%2C/0/default.jpg',
      out: '/B28573286.JP2/full/1338%2C/0/default.jpg'
    },
    {
      in: '/image/b17548779_0001.jp2/full/1338%2C/0/default.jpg',
      out: '/b17548779_0001.jp2/full/1338%2C/0/default.jpg'
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

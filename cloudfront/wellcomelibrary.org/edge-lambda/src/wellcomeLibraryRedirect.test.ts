import * as origin from './wellcomeLibraryRedirect';
import testRequest from './testEventRequest';
import {Context} from 'aws-lambda';

import axios from 'axios';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

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
  async (expected: ExpectedRewrite) => {
    const event = testRequest(expected.in);

    // mockedAxios.get.mockResolvedValueOnce({ data: {} });

    const originRequest = await origin.request(event, {} as Context)

    expect(originRequest.uri).toBe(expected.out);
  }
);

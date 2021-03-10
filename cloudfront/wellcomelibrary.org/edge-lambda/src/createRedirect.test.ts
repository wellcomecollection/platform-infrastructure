import { expect, test } from '@jest/globals';
import { createRedirect } from './createRedirect';
import { CloudFrontResultResponse } from 'aws-lambda';

test('returns a valid redirect', async () => {
  const redirect: CloudFrontResultResponse = createRedirect(
    'https://www.example.com'
  );

  // Temporary redirect should be updated to permanent when redirections are stable
  expect(redirect.status).toEqual('302');
  const headers = redirect.headers;
  expect(headers).toEqual({
    location: [
      {
        key: 'Location',
        value: 'https://www.example.com',
      },
    ],
  });
});

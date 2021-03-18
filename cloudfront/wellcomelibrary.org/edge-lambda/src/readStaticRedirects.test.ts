import { expect, test } from '@jest/globals';
import { readStaticRedirects } from './readStaticRedirects';
import path from 'path';

test('parses redirects from a CSV', async () => {
  const fileLocation = path.resolve(
    __dirname,
    'readStaticRedirectsFixture.csv'
  );
  const expectedRedirects = {
    '/no-host': 'https://wellcomecollection.org/no-host',
    '/no-slash-prefix': 'https://wellcomecollection.org/no-slash-prefix',
    '/no-trailing-slash': 'https://wellcomecollection.org/no-trailing-slash',
    '/trailing-slash': 'https://wellcomecollection.org/trailing-slash',
  };

  const staticRedirects = await readStaticRedirects(fileLocation);

  expect(staticRedirects).toStrictEqual(expectedRedirects);
});

test('fails parsing if duplicate records exist', async () => {
  const fileLocation = path.resolve(
    __dirname,
    'readStaticRedirectsFixtureDupes.csv'
  );
  const expectedError = Error(
    'Cannot parse CSV into redirects, duplicate paths exist for /dupe!'
  );

  await expect(readStaticRedirects(fileLocation)).rejects.toThrow(
    expectedError
  );
});

import { expect, test } from '@jest/globals';
import { readRedirects } from './readRedirects';
import path from 'path';

test('parses redirects from a CSV', async () => {
  const fileLocation = path.resolve(
    __dirname,
    'csvFixtures/readRedirectsFixture.csv'
  );
  const expectedRedirects = {
    '/trailing-slash': 'https://wellcomecollection.org/trailing-slash',
    '/no-trailing-slash': 'https://wellcomecollection.org/no-trailing-slash',
    '/': 'https://wellcomecollection.org/',
  };

  const expectedHostPrefix = 'wellcomelibrary.org';
  const staticRedirects = await readRedirects(fileLocation, expectedHostPrefix);

  expect(staticRedirects).toStrictEqual(expectedRedirects);
});

test('fails parsing if duplicate records exist', async () => {
  const fileLocation = path.resolve(
    __dirname,
    'csvFixtures/readRedirectsFixtureDupes.csv'
  );
  const expectedError = Error(
    'Cannot parse CSV into redirects, duplicate paths exist for /dupe!'
  );
  const expectedHostPrefix = 'wellcomelibrary.org';

  await expect(readRedirects(fileLocation, expectedHostPrefix)).rejects.toThrow(
    expectedError
  );
});

test('fails parsing if unexpected hostPrefix found', async () => {
  const fileLocation = path.resolve(
    __dirname,
    'csvFixtures/readRedirectFixtureBadHost.csv'
  );
  const expectedError = Error(
    'Source row does not start with expected prefix: wellcomelibrary.org (badhost.com/no-host)'
  );
  const expectedHostPrefix = 'wellcomelibrary.org';

  await expect(readRedirects(fileLocation, expectedHostPrefix)).rejects.toThrow(
    expectedError
  );
});

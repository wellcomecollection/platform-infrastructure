import * as path from 'path';
import * as fs from 'fs';

import assert from 'assert';
import { readRedirects } from './src/readRedirects';

export const staticRedirectFileLocation = path.resolve(
  __dirname,
  'staticRedirects.csv'
);
export const staticRedirectHeaders = [
  undefined,
  'sourceUrl',
  'targetUrl',
  undefined,
  undefined,
];
export const staticRedirectsHost = 'wellcomelibrary.org';

async function generateRedirects() {
  const redirectsData = await readRedirects(
    staticRedirectFileLocation,
    staticRedirectsHost,
    staticRedirectHeaders
  );
  const redirectsJson = JSON.stringify(redirectsData, null, 2);

  fs.writeFileSync('src/staticRedirects.json', redirectsJson);
}

async function verifyRedirects() {
  const jsonFileLocation = path.resolve(
    __dirname,
    './src/staticRedirects.json'
  );
  const jsonData = fs.readFileSync(jsonFileLocation, 'utf8');
  const rawStaticRedirects = JSON.parse(jsonData);

  const existingRedirects = rawStaticRedirects as Record<string, string>;
  const generatedRedirects = await readRedirects(
    staticRedirectFileLocation,
    staticRedirectsHost,
    staticRedirectHeaders
  );

  assert(
    JSON.stringify(generatedRedirects) === JSON.stringify(existingRedirects),
    'Generated redirects do not match those in ./src! Do you need to commit changes?'
  );
}

if (process.argv[2] === 'verify') {
  verifyRedirects().catch((error) => {
    console.error(error);
    process.exit(1);
  });
} else {
  generateRedirects().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

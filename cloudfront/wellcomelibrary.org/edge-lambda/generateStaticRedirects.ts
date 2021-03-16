import * as csv from '@fast-csv/parse';
import * as path from 'path';
import * as fs from 'fs';

import rawStaticRedirects from './src/staticRedirects.json';
import assert from 'assert';
const existingRedirects = rawStaticRedirects as Record<string, string>;

type RedirectRow = {
  libraryUrl: string;
  collectionUrl: string;
};

export function readStaticRedirects(): Promise<Record<string, string>> {
  const fileLocation = path.resolve(__dirname, 'redirects.csv');
  const options = {
    skipLines: 1,
    headers: [undefined, 'libraryUrl', 'collectionUrl', undefined, undefined],
  };

  return new Promise((resolve, reject) => {
    const redirects: Record<string, string> = {};

    csv
      .parseFile<RedirectRow, RedirectRow>(fileLocation, options)
      .on('error', reject)
      .on('data', (row: RedirectRow) => {
        const lookupKey = row.libraryUrl
          // Remove hostname
          .replace('wellcomelibrary.org', '')
          // Strip trailing slash
          .replace(/\/$/, '');
        redirects[lookupKey] = row.collectionUrl;
      })
      .on('end', () => {
        resolve(redirects);
      });
  });
}

async function generateRedirects() {
  const redirectsData = await readStaticRedirects();
  const redirectsJson = JSON.stringify(redirectsData, null, 2);

  fs.writeFileSync('src/staticRedirects.json', redirectsJson);
}

async function verifyRedirects() {
  const generatedRedirects = await readStaticRedirects();

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

import * as csv from '@fast-csv/parse';

type RedirectRow = {
  libraryUrl: string;
  collectionUrl: string;
};

export function readStaticRedirects(
  fileLocation: string
): Promise<Record<string, string>> {
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
        if (row.libraryUrl) {
          const lookupKey = row.libraryUrl
            // Remove hostname
            .replace('wellcomelibrary.org', '')
            // Strip slash suffix
            .replace(/\/$/, '')
            // Ensure slash prefix
            .replace(/^\/?/, '/');

          if (lookupKey in redirects) {
            throw Error(
              `Cannot parse CSV into redirects, duplicate paths exist for ${lookupKey}!`
            );
          }

          if (lookupKey) {
            redirects[lookupKey] = row.collectionUrl;
          }
        }
      })
      .on('end', () => {
        resolve(redirects);
      });
  });
}

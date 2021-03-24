import * as csv from '@fast-csv/parse';
import { ParserOptionsArgs } from '@fast-csv/parse';

type RedirectRow = {
  sourceUrl: string;
  targetUrl: string;
};

export type CsvHeader = undefined | string;

export function readRedirects(
  fileLocation: string,
  hostPrefix: string,
  headers: CsvHeader[]
): Promise<Record<string, string>> {
  const options = {
    skipLines: 1,
    headers: headers,
    strictColumnHandling: true,
    discardUnmappedColumns: true,
  } as ParserOptionsArgs;

  return new Promise((resolve, reject) => {
    const redirects: Record<string, string> = {};

    csv
      .parseFile<RedirectRow, RedirectRow>(fileLocation, options)
      .on('error', reject)
      .on('data', (row: RedirectRow) => {
        if (row.sourceUrl) {
          if (!row.sourceUrl.startsWith(hostPrefix)) {
            throw Error(
              `Source row does not start with expected prefix: ${hostPrefix} (${row.sourceUrl})`
            );
          }

          const lookupKey = row.sourceUrl
            .trim()
            // Remove hostname
            .replace(hostPrefix, '')
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
            redirects[lookupKey] = row.targetUrl.trim();
          }
        }
      })
      .on('end', () => {
        resolve(redirects);
      });
  });
}

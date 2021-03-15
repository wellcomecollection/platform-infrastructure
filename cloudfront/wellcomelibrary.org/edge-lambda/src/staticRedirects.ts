import * as csv from '@fast-csv/parse';
import path from "path";

type RedirectRow = {
    libraryUrl: string;
    collectionUrl: string;
};

// TODO: Consider pre-generating JSON in build step
export function readStaticRedirects(): Promise<Record<string, string>> {
    const fileLocation = path.resolve(__dirname, 'redirects.csv')
    const options = {skipLines: 1, headers: [undefined, 'libraryUrl', 'collectionUrl', undefined, undefined]}
    return new Promise((resolve, reject) => {
        let redirects: Record<string, string> = {}

        csv.parseFile<RedirectRow, RedirectRow>(fileLocation, options)
            .on("error", reject)
            .on("data", (row: RedirectRow) => {
                const lookupKey = row.libraryUrl.replace('wellcomelibrary.org', '')
                redirects[lookupKey] = row.collectionUrl
            })
            .on("end", () => {
                resolve(redirects);
            });
    });
}

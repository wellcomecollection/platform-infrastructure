import axios, {AxiosRequestConfig, AxiosResponse} from 'axios';
import chalk from 'chalk';

import { readRedirects } from './src/readRedirects';
import {
  staticRedirectFileLocation,
  staticRedirectHeaders,
  staticRedirectsHost,
} from './staticRedirects';

type CsvHeader = string | undefined;

type RedirectCheck = Error | undefined;

type HostEnvs = {
  prod?: string;
  stage?: string;
};
type EnvId = keyof HostEnvs;

const prod: EnvId = 'prod';
const stage: EnvId = 'stage';

type RedirectResult = {
  error?: Error;
  fromPath: string;
  from: string;
  to: string;
};

type ResultSet = {
  host: string;
  results: RedirectResult[];
};

type RedirectTestSet = {
  displayName: string;
  fileLocation: string;
  fileHostPrefix: string;
  headers: CsvHeader[];
  envs: HostEnvs;
  results?: ResultSet;
  checkRedirect: (response: AxiosResponse<any>, toUrl: string) => RedirectCheck;
};

async function testRedirects(env: EnvId, redirectTestSet: RedirectTestSet) {
  let host: string | undefined;

  switch (env) {
    case prod:
      host = redirectTestSet.envs.prod;
      break;
    case stage:
      host = redirectTestSet.envs.stage;
      break;
  }

  if (!host) {
    return redirectTestSet;
  }

  const pathTests: Record<string, string> = await readRedirects(
    redirectTestSet.fileLocation,
    redirectTestSet.fileHostPrefix,
    redirectTestSet.headers
  );

  const eventuallyResults = Object.entries(pathTests).map(
    async ([fromPath, to]) => {
      const from = `${host}${fromPath}`;

      const redirectResult = {
        to: to,
        fromPath: fromPath,
        from: from,
      } as RedirectResult;

      const axiosConfig: AxiosRequestConfig = {
        maxRedirects: 0,
        // The default validation excludes redirects
        validateStatus: (status: number) => status >= 200 && status < 400
      }

      try {
        redirectResult.error = redirectTestSet.checkRedirect(
          await axios.get(from, axiosConfig),
          to
        );
      } catch (e) {
        redirectResult.error = e;
      }

      return redirectResult;
    }
  );

  const testResults = await Promise.all(eventuallyResults);

  redirectTestSet.results = {
    host: host,
    results: testResults,
  };

  return redirectTestSet;
}

const displayResultSet = (redirectTestSet: RedirectTestSet) => {
  console.log(chalk.blue.underline.bold(`\n${redirectTestSet.displayName}`));

  if (redirectTestSet.results) {
    const resultSet = redirectTestSet.results;
    console.log(chalk.blue.bold(`${resultSet.host}`));

    resultSet.results.forEach((result) => {
      if (result.error) {
        console.error(chalk.red(`✘ ${result.from}\n${result.error}`));
      } else {
        console.info(chalk.green(`✓ ${result.fromPath}`));
      }
    });
  } else {
    console.info('No results');
  }

  return redirectTestSet;
};

const checkMatchingUrl = (axiosResponse: AxiosResponse, toUrl: string) => {
  const redirectUrl = axiosResponse.headers.location;

  if (redirectUrl !== toUrl) {
    return Error(`Response: ${redirectUrl}\nExpected: ${toUrl}`);
  }
};

const checkMatchingBlogUrl = (axiosResponse: AxiosResponse, toUrl: string) => {
  const redirectUrl = axiosResponse.headers.location;
  const wayBackBaseUrl = 'https://wayback.archive-it.org/16107';

  if (!redirectUrl.startsWith(wayBackBaseUrl)) {
    return Error(`Response: ${redirectUrl} must start with ${wayBackBaseUrl}`);
  }

  if (!redirectUrl.endsWith(toUrl)) {
    return Error(`Response: ${redirectUrl} must end with ${toUrl}`);
  }
};

const apiTestSet = {
  displayName: 'Library API',
  fileLocation: 'apiRedirects.csv',
  fileHostPrefix: 'wellcomelibrary.org',
  headers: ['sourceUrl', 'targetUrl'],
  envs: {
    stage: 'https://stage.wellcomelibrary.org',
    prod: 'https://wellcomelibrary.org',
  },
  checkRedirect: checkMatchingUrl,
};

const itemTestSet = {
  displayName: 'Item pages',
  fileLocation: 'itemRedirects.csv',
  fileHostPrefix: 'wellcomelibrary.org',
  headers: staticRedirectHeaders,
  envs: {
    stage: 'https://stage.wellcomelibrary.org',
    prod: 'https://wellcomelibrary.org',
  },
  checkRedirect: checkMatchingUrl,
};

const blogTestSet = {
  displayName: 'Library blog',
  fileLocation: 'blogRedirects.csv',
  fileHostPrefix: 'blog.wellcomelibrary.org',
  headers: ['sourceUrl', 'targetUrl'],
  envs: {
    stage: 'https://blog.stage.wellcomelibrary.org',
    prod: 'https://blog.wellcomelibrary.org',
  },
  checkRedirect: checkMatchingBlogUrl,
};

const apexTestSet = {
  displayName: 'Apex (Content management) pages',
  fileLocation: staticRedirectFileLocation,
  fileHostPrefix: staticRedirectsHost,
  headers: staticRedirectHeaders,
  envs: {
    stage: 'https://stage.wellcomelibrary.org',
    prod: 'https://wellcomelibrary.org',
  },
  checkRedirect: checkMatchingUrl,
};

const archiveTestSet = {
  displayName: 'Archive search',
  fileLocation: 'archiveRedirects.csv',
  fileHostPrefix: 'archives.wellcomelibrary.org',
  headers: ['sourceUrl', 'targetUrl'],
  envs: {
    stage: 'https://archives.stage.wellcomelibrary.org',
    prod: 'https://archives.wellcomelibrary.org',
  },
  checkRedirect: checkMatchingUrl,
};

const collectionBrowseTestSet = {
  displayName: 'Collection browse pages',
  fileLocation: 'collectionsBrowse.csv',
  fileHostPrefix: 'wellcomelibrary.org',
  headers: ['sourceUrl', 'targetUrl'],
  envs: {
    stage: 'https://stage.wellcomelibrary.org',
    prod: 'https://wellcomelibrary.org',
  },
  checkRedirect: checkMatchingUrl,
};

const testSets: RedirectTestSet[] = [
  apiTestSet,
  itemTestSet,
  blogTestSet,
  apexTestSet,
  archiveTestSet,
  collectionBrowseTestSet,
];

const runTests = async (envId: EnvId) => {
  const testResults = await Promise.all(
    testSets
      .map(async (testSet) => await testRedirects(envId, testSet))
      .map(async (resultsSet) => displayResultSet(await resultsSet))
  );

  const foundErrors = testResults.filter(
    (testSet) =>
      testSet.results && testSet.results.results.find((result) => result.error)
  );

  if (foundErrors.length >= 1) {
    console.error(chalk.red(`\nFound failed redirects! ✘✘✘`));
    process.exit(1);
  } else {
    console.log(chalk.greenBright(`\nAll redirections successful ✓✓✓`));
  }
};

runTests(process.argv[2] as EnvId);

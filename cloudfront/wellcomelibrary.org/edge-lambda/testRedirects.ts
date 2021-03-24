import axios from 'axios';
import chalk from 'chalk';

import { readRedirects } from './src/readRedirects';
import {
  staticRedirectFileLocation,
  staticRedirectHeaders,
  staticRedirectsHost,
} from './staticRedirects';

type CsvHeader = string | undefined;
type EnvId = 'stage' | 'prod';

type HostEnvs = {
  prod?: string;
  stage?: string;
};

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
  displayName: string
  fileLocation: string;
  fileHostPrefix: string;
  headers: CsvHeader[];
  envs: HostEnvs;
  results?: ResultSet
};

async function testRedirects(env: EnvId, redirectTestSet: RedirectTestSet) {
  const host =
    env === 'stage' ? redirectTestSet.envs.stage : redirectTestSet.envs.prod;

  if(!host) {
    return redirectTestSet;
  }

  const pathTests: Record<string, string> = await readRedirects(
    redirectTestSet.fileLocation,
    redirectTestSet.fileHostPrefix,
    redirectTestSet.headers
  );

  const testResults = await Promise.all(
    Object.entries(pathTests).map(async ([fromPath, to]) => {
      const from = `${host}${fromPath}`;

      const redirectResult = {
        to: to,
        fromPath: fromPath,
        from: from,
      } as RedirectResult;

      try {
        const axiosResponse = await axios.get(from);
        const responseUrl = axiosResponse.request.res.responseUrl;

        redirectResult.error =
          responseUrl != to
            ? Error(`Response: ${responseUrl}\nExpected: ${to}`)
            : undefined;
      } catch (e) {
        redirectResult.error = e;
      }

      return redirectResult;
    })
  );

  redirectTestSet.results = {
    host: host,
    results: testResults,
  }

  return redirectTestSet;
}

const displayResultSet = (redirectTestSet: RedirectTestSet) => {
  console.log(chalk.blue.underline.bold(`\n${redirectTestSet.displayName}`));

  if(redirectTestSet.results) {
    const resultSet = redirectTestSet.results
    console.log(chalk.blue.bold(`${resultSet.host}`));

    resultSet.results.forEach((result) => {
      if (result.error) {
        console.error(chalk.red(`✘ ${result.from}\n${result.error}`));
      } else {
        console.info(chalk.green(`✓ ${result.fromPath}`));
      }
    });
  } else {
    console.info('No results')
  }

  return redirectTestSet
};

const itemTestSet = {
  displayName: 'Item pages',
  fileLocation: 'itemRedirects.csv',
  fileHostPrefix: 'wellcomelibrary.org',
  headers: staticRedirectHeaders,
  envs: {
    stage: 'http://stage.wellcomelibrary.org',
    // prod: 'http://wellcomelibrary.org',
  },
};

const blogTestSet = {
  displayName: 'Library blog',
  fileLocation: 'blogRedirects.csv',
  fileHostPrefix: 'blog.wellcomelibrary.org',
  headers: ['sourceUrl', 'targetUrl'],
  envs: {
    stage: 'http://blog.stage.wellcomelibrary.org/',
    // prod: 'http://blog.wellcomelibrary.org/',
  },
};

const apexTestSet = {
  displayName: 'Apex (Content management) pages',
  fileLocation: staticRedirectFileLocation,
  fileHostPrefix: staticRedirectsHost,
  headers: staticRedirectHeaders,
  envs: {
    stage: 'http://stage.wellcomelibrary.org',
    prod: 'http://wellcomelibrary.org',
  },
};

const testSets: RedirectTestSet[] = [itemTestSet,blogTestSet,apexTestSet];

const runTests = async (envId: EnvId) => {
  const testResults = await Promise.all(testSets
      .map(async (testSet) => await testRedirects(envId, testSet))
      .map(async (resultsSet) => displayResultSet(await resultsSet))
  );

  const foundErrors = testResults.filter(testSet =>
    testSet.results && testSet.results.results.find(result => result.error)
  )

  if(foundErrors.length >= 1) {
    console.error(chalk.red(`\nFound failed redirects! ✘✘✘`));
    process.exit(1)
  } else {
    console.log(chalk.greenBright(`\nAll redirections successful ✓✓✓`));
  }
}

runTests(process.argv[2] as EnvId);

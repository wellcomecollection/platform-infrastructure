import path from 'path';
import fs from 'fs';
import axios from 'axios';
import chalk from 'chalk';

type RedirectTest = {
  host: string;
  pathTests: Record<string, string>;
};

type HostEnvs = {
  prod: string;
  stage: string;
};

type EnvId = 'stage' | 'prod';

type RedirectTestSet = (env: EnvId) => RedirectTest;

type RedirectResult = {
  error: undefined | Error;
  fromPath: string;
  from: string;
  to: string;
};

type ResultSet = {
  host: string;
  results: RedirectResult[];
};

async function testRedirects(tests: RedirectTest) {
  const testResults = await Promise.all(
    Object.entries(tests.pathTests).map(async ([fromPath, to]) => {
      const from = `${tests.host}${fromPath}`;

      const redirectResult: RedirectResult = {
        to: to,
        fromPath: fromPath,
        from: from,
        error: undefined,
      };

      try {
        const axiosResponse = await axios.get(from);
        const responseUrl = axiosResponse.request.res.responseUrl;

        redirectResult.error =
          responseUrl !== to
            ? Error(`${from}: ${responseUrl} !== ${to}`)
            : undefined;
      } catch (e) {
        redirectResult.error = e;
      }

      return redirectResult;
    })
  );

  return {
    host: tests.host,
    results: testResults,
  } as ResultSet;
}

// Blog tests
const getBlogTests: RedirectTestSet = (env: EnvId) => {
  const blogEnvs: HostEnvs = {
    stage: 'http://blog.stage.wellcomelibrary.org/',
    prod: 'http://blog.wellcomelibrary.org/',
  };

  const host = env === 'stage' ? blogEnvs.stage : blogEnvs.prod;

  const blogRedirectPaths = {
    '/2018/05/goodbye-from-wellcome-library-blog/':
      'https://wayback.archive-it.org/16107-test/20210302041159/http://blog.wellcomelibrary.org/2018/05/goodbye-from-wellcome-library-blog/',
    '/':
      'https://wayback.archive-it.org/16107-test/20210301155649/http://blog.wellcomelibrary.org/',
  };

  return {
    host: host,
    pathTests: blogRedirectPaths,
  };
};

// Apex tests
const getApexTests: RedirectTestSet = (env: EnvId) => {
  const apexEnvs: HostEnvs = {
    stage: 'http://stage.wellcomelibrary.org',
    prod: 'http://wellcomelibrary.org',
  };

  const host = env === 'stage' ? apexEnvs.stage : apexEnvs.prod;

  const jsonFileLocation = path.resolve(
    __dirname,
    './src/staticRedirects.json'
  );
  const jsonData = fs.readFileSync(jsonFileLocation, 'utf8');
  const rawStaticRedirects = JSON.parse(jsonData);

  const apexStaticRedirectPaths = rawStaticRedirects as Record<string, string>;

  return {
    host: host,
    pathTests: apexStaticRedirectPaths,
  };
};

const testSets: RedirectTestSet[] = [getBlogTests, getApexTests];

const displayResultSet = (resultSet: ResultSet) => {
  console.log(chalk.blue.underline.bold(`\n${resultSet.host}`));
  resultSet.results.forEach((result) => {
    if (result.error) {
      console.error(chalk.red(`✘ ${result.from}: ${result.error}`));
    } else {
      console.info(chalk.green(`✓ ${result.fromPath}`));
    }
  });
};

const runTests = async (env: EnvId) =>
  testSets
    .map((getTests) => getTests(env))
    .map(async tests => await testRedirects(tests))
    .forEach(async resultsSet => displayResultSet(await resultsSet));

runTests(process.argv[2] as EnvId);

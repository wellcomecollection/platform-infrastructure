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

async function testRedirects(tests: RedirectTest) {
  Object.entries(tests.pathTests).map(async ([fromPath, to]) => {
    const from = `${tests.host}${fromPath}`;

    try {
      const axiosResponse = await axios.get(from);
      const responseUrl = axiosResponse.request.res.responseUrl;
      if (responseUrl === to) {
        console.info(chalk.green(`✓ ${from} === ${responseUrl}`));
      } else {
        console.error(chalk.red(`✘ ${from}: ${responseUrl} !== ${to}`));
      }
    } catch (e) {
      console.error(chalk.red(`✘ ${from}: ${e}`));
    }
  });
}

// Blog tests

function getBlogTests(env: EnvId): RedirectTest {
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
}

// Apex tests
function getApexTests(env: EnvId): RedirectTest {
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
}

// TODO: Partition tests by section
async function runTests(env: EnvId) {
  const blogTests = getBlogTests(env);
  await testRedirects(blogTests);

  const apexTests = getApexTests(env);
  await testRedirects(apexTests);
}

if (process.argv[2] === 'stage') {
  runTests('stage');
} else {
  runTests('prod');
}

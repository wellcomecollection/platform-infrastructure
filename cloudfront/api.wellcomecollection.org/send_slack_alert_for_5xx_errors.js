/** Identify errors in the CloudFront logs and post them to Slack.
 *
 * Our CloudFront logs get written to an S3 bucket.  This is the source code
 * of a Lambda function that:
 *
 *    1. Listens to the event stream from the bucket
 *    2. Gets notified of new logs being written to the bucket
 *    3. Reads new logs, and filters for 5xx errors
 *    4. If there are any, sends a list of those URLs to a shared Slack channel
 *
 * This tells us if something is broken, and helps us target our debugging.
 *
 * (As opposed to our previous approach, which dropped a vague metric telling us
 * there were errors, but with no way to identify which app was the source of
 * the errors.  Now we know which app's logs we should be checking first.)
 *
 * It's written in vanilla JavaScript/Node because it's pretty simple, and
 * it simplifies the process of deployment.
 *
 */

const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3")
const events = require('events');
const https = require('https');
const readline = require('readline');
const zlib = require('zlib');

/** Reads a CloudFront log file and returns structured log events.
 *
 * CloudFront logs are semi-structured files, where the top two lines are
 * a header, then subsequent lines are tab-separated values, e.g.:
 *
 *      #Version: 1.0
 *      #Fields: date time cs-uri-stem
 *      2022-05-18	14:11:10	/works
 *      2022-05-18	14:11:09	/works/atry66dj/items
 *
 * This function emits objects so that downstream callers don't need
 * to know about the structure of this file, e.g.
 *
 *      { date: '2022-05-18', time: '14:11:10', cs-uri-stem: '/search/works' }
 *      { date: '2022-05-18', time: '14:11:09', cs-uri-stem: '/works/atry66dj/items' }
 *
 */
async function findCloudFrontHitsFromLog(bucket, key, region) {
  const s3Client = new S3Client({ region })
  const GetObjectCommandOutput = await s3Client.send(
    new GetObjectCommand({ Bucket: bucket, Key: key })
  )

  const input = GetObjectCommandOutput.Body.pipe(zlib.createGunzip())
  const lineReader = readline.createInterface({ input: input });

  let fields = [];
  let result = [];

  lineReader.on('line', line => {
    // Skip the first header line.
    if (line.startsWith('#Version')) {
    }
    // The second line tells us what the fields are.
    else if (line.startsWith('#Fields')) {
      fields = line.replace('#Fields:', '').trim().split(' ');
    }
    // All subsequent lines are values.
    else {
      const values = line.trim().split('\t');
      const hit = Object.assign(...fields.map((k, i) => ({ [k]: values[i] })));

      result.push({
        protocol: hit['cs-protocol'],
        host: hit['x-host-header'],
        path: decodeURIComponent(hit['cs-uri-stem']),
        ipAddress: hit['c-ip'],
        date: new Date(`${hit['date']}T${hit['time']}Z`),

        // The CloudFront log records this as a string, but it's more convenient
        // downstream if we can treat it as a number.
        status: parseInt(hit['sc-status']),

        // Note: if the request contained an empty query string, CloudFront
        // will log this as '-'
        query: hit['cs-uri-query'] !== '-' ? decodeURIComponent(hit['cs-uri-query']) : null,
      });

      result.push(hit);
    }
  });

  await events.once(lineReader, 'close');

  return result;
}

/** Prints a human-readable description of a number, e.g. "5.2K" or "6M". */
function humanize(n) {
  if (n < 1000) {
    return `${n}`;
  } else if (n < 1000 * 1000) {
    return `${Math.round(n / 100) / 10}K`;
  } else {
    return `${Math.round(n / (100 * 1000)) / 10}M`;
  }
}

/** Returns the earliest date from a list. */
function minDate(dates) {
  console.assert(dates.length > 0);
  return dates.reduce((a, b) => (a < b ? a : b));
}

/** Returns the latest date from a list. */
function maxDate(dates) {
  console.assert(dates.length > 0);
  return dates.reduce((a, b) => (a > b ? a : b));
}

/** Create a pre-filled link to Kibana logs for the front-end apps.
 *
 * This link is meant to filter out happy path traffic that isn't a 5xx error,
 * e.g. 200 OK or 404 Not Found responses.
 */
function createKibanaLogLink(serverErrors) {
  // Find the time of the earliest/latest error, then add an hour either
  // side for safety.
  const earliestError = minDate(serverErrors.map(e => e.date));
  const latestError = maxDate(serverErrors.map(e => e.date));

  const fromDate = new Date(
    earliestError.setMinutes(earliestError.getMinutes() - 60)
  );
  const toDate = new Date(latestError.setMinutes(latestError.getMinutes() + 60));

  return `https://logging.wellcomecollection.org/app/discover#?_g=(filters%3A!()%2CrefreshInterval%3A(pause%3A!t%2Cvalue%3A0)%2Ctime%3A(from%3A'${fromDate.toISOString()}'%2Cto%3A'${toDate.toISOString()}'))`;
}

/** Send a message to Slack describing the errors.
 *
 * This includes a list of the erroring URLs.  Note that it's written
 * to a public Slack channel, so we need to be a bit careful what we log.
 */
async function sendSlackMessage(bucket, key, region, serverErrors, hits) {
  const lines = serverErrors.map(function (e) {
    const url = createDisplayUrl(e.protocol, e.host, e.path, e.query);

    // We assume that most errors are generic 500 errors, but non-500 codes
    // might be interesting and worth highlighting.
    return e.status === 500 ? url : `${url} (${e.status})`;
  });

  // This creates a Markdown-formatted message like:
  //
  //    5 errors / 5K requests / [View app logs in Kibana] / [View CloudFront logs in S3]
  //    ```
  //    https://example.org/badness
  //    https://example.org/more-badness
  //    ```
  //
  // Note: we put the summary message first so that if there are lots of lines with
  // errors, the summary doesn't get truncated off the end.
  //
  // e.g. https://wellcome.slack.com/archives/CQ720BG02/p1659031456721909
  //
  const cloudfrontUrl = `https://${region}.console.aws.amazon.com/s3/object/${bucket}?region=${region}&prefix=${key}`;
  const kibanaUrl = createKibanaLogLink(serverErrors);

  const errorCount = `${humanize(lines.length)} error${
    lines.length > 1 ? 's' : ''
  }`;
  const requestCount = `${humanize(hits.length)} request${
    hits.length > 1 ? 's' : ''
  }`;

  const message =
    `${errorCount} / ${requestCount} / <${kibanaUrl}|View app logs in Kibana> / <${cloudfrontUrl}|View CloudFront logs in S3>\n` +
    '```\n' +
    lines.join('\n') +
    '\n```';

  const slackPayload = {
    username: `CloudFront: 5xx error${lines.length > 1 ? 's' : ''} detected`,
    icon_emoji: ':rotating_light:',
    attachments: [
      {
        color: 'danger',
        fallback: 'cloudfront-errors',
        fields: [
          {
            value: message,
          },
        ],
      },
    ],
  };

  const webhookUrl = process.env.WEBHOOK_URL;

  await post(webhookUrl, slackPayload);
}

function createDisplayUrl(protocol, host, path, query) {
  if (query === null) {
    return `${protocol}://${host}${path}`;
  } else {
    return `${protocol}://${host}${path}?${query}`;
  }
}

/** Post data to a given URL.
 *
 * This is a generic helper function written by Rasool Khan on
 * Stack Overflow: https://stackoverflow.com/a/40539133/1558022
 *
 * Used under the Stack Exchange CC BY-SA license.
 */
async function post(url, data) {
  const dataString = JSON.stringify(data);

  const options = {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': dataString.length,
    },
    timeout: 1000, // in ms
  };

  return new Promise((resolve, reject) => {
    const req = https.request(url, options, res => {
      if (res.statusCode < 200 || res.statusCode > 299) {
        return reject(new Error(`HTTP status code ${res.statusCode}`));
      }

      const body = [];
      res.on('data', chunk => body.push(chunk));
      res.on('end', () => {
        const resString = Buffer.concat(body).toString();
        resolve(resString);
      });
    });

    req.on('error', err => {
      reject(err);
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request time out'));
    });

    req.write(dataString);
    req.end();
  });
}

function isError(hit) {
  return hit.status >= 500;
}

function isInterestingError(hit) {
  // We ignore errors on the CloudFront domain because nobody should
  // be using it; it's probably somebody malicious.
  if (hit.host.endsWith('cloudfront.net')) {
    return false;
  }

  // It turns out the ALB will throw a 503 Gateway Error if you try
  // to request a URL that includes a percent-encoded newline; here's
  // a minimal example:
  //
  //      https://wellcomecollection.org/%0A%20
  //
  // We've seen this occasionally when somebody tries to append an SVG
  // as a data-uri to requests.  This generates a noisy Slack log.
  //
  // We can't do anything about this, so ignore it.
  //
  if (
    hit.status === 503 &&
    (hit.path.indexOf('%0A') !== -1 || hit.path.indexOf('%0a') !== -1)
  ) {
    return false;
  }

  // This is the Elastic IP address of the platform AWS account;
  // errors here are probably in our end-to-end tests.
  //
  // Since we already get alerts for the e2e tests and they can be
  // very chatty when something goes wrong, ignore these errors.
  if (hit.ipAddress === '54.216.243.181') {
    return false;
  }

  // We've seen requests for very long query strings that result in
  // an HTTP 503 timeout from the API.
  //
  // There's not a lot we can do about these, and they're usually
  // people putting spam into the API, so ignore them.
  //
  // This heuristic is deliberately quite hard to hit -- it has to
  // be both a timeout and have a high frequency of %C2 or %C3, which
  // are the first byte of multi-byte Unicode characters which don't
  // fit into a single byte.  This should filter out bogus requests but
  // avoid dropping errors from legitimate queries.
  if (
    hit.status === 503 &&
    (hit.query?.split('%C3').length > 70 || hit.query?.split('%25C2').length > 80)
  ) {
    return false;
  }

  return true;
}

exports.handler = async event => {
  // This Lambda receives event notifications from S3.
  //
  // We only care about the affected objects; extract this information
  // from the event.
  const affectedObjects = event.Records.map(function (r) {
    return {
      region: r.awsRegion,
      bucket: r.s3.bucket.name,
      key: r.s3.object.key,
    };
  });

  for (const s3Object of affectedObjects) {
    console.info(
      `Inspecting CloudFront logs for s3://${s3Object.bucket}/${s3Object.key}`
    );

    const hits = await findCloudFrontHitsFromLog(s3Object.bucket, s3Object.key, s3Object.region);
    const serverErrors = hits.filter(isError);
    const interestingErrors = serverErrors.filter(isInterestingError);

    if (interestingErrors.length === 0 && serverErrors.length === 0) {
      console.info('No errors in this log file, nothing to do');
    } else if (interestingErrors.length === 0) {
      console.info(
        `Detected ${serverErrors.length} error(s) in this log file, but nothing interesting, nothing to do`
      );
    } else {
      console.info(
        `Detected ${serverErrors.length} error(s) and ${interestingErrors.length} interesting error(s), sending message to Slack`
      );
      await sendSlackMessage(
        s3Object.bucket,
        s3Object.key,
        s3Object.region,
        interestingErrors,
        hits
      );
    }
  }
};

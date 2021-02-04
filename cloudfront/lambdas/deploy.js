const AWS = require('aws-sdk');

const roleCredentials = new AWS.ChainableTemporaryCredentials({
  params: {RoleArn: 'arn:aws:iam::760097843905:role/platform-ci'}
});

const s3 = new AWS.S3({ apiVersion: '2006-03-01' , credentials: roleCredentials});

const fs = require('fs');

try {
  const data = fs.readFileSync('dist/lambda.zip');

  const params = {
    Body: data,
    Bucket: 'wellcomecollection-platform-infra',
    Key: 'lambdas/infrastructure/cloudfront/lambda.zip',
    ACL: 'private',
    ContentType: 'application/zip',
  };

  s3.putObject(params, function(err, data) {
    if (err) console.log(err, err.stack);
    else console.log('Finished uploading edge_lambda_origin.zip');
  });

} catch (e) {
  console.log('Error:', e.stack);
}

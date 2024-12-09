const zipLocation = 'dist/dlcs_path_rewrite.zip'
const s3Bucket = 'wellcomecollection-edge-lambdas'
const s3Key = 'iiif/dlcs_path_rewrite.zip'
const roleArn = 'arn:aws:iam::760097843905:role/platform-ci'

const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3")
const { fromTemporaryCredentials } = require("@aws-sdk/credential-providers")
const fs = require("fs")

const s3Client = new S3Client({
  region: "us-east-1",
  credentials: fromTemporaryCredentials({
    params: {
      RoleArn: roleArn,
    },
    clientConfig: { region: "us-east-1" },
  }),
});

try {
  const data = fs.readFileSync(zipLocation)

  const command = new PutObjectCommand({
    Bucket: s3Bucket,
    Key: s3Key,
    Body: data,
    ACL: 'private',
    ContentType: 'application/zip'
  })

  s3Client.send(command, function(err, data) {
    if (err) console.log(err, err.stack)
    else console.log(`Finished uploading ${zipLocation} to s3://${s3Bucket}/${s3Key}`)
  })

} catch (e) {
  console.log('Error:', e.stack);
}

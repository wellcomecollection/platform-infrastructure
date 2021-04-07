import { SNSHandler } from "aws-lambda/trigger/sns";
import * as aws from "aws-sdk";

export const handler: SNSHandler = async (event) => {
  const distro = process.env.DISTRIBUTION_ID;

  const paths = JSON.parse(event.Records[0].Sns.Message);

  const cloudfront = new aws.CloudFront();
  const params = {
    DistributionId: distro,
    InvalidationBatch: {
      CallerReference: `${Date.now()}`,
      Paths: {
        Quantity: paths.length,
        Items: paths,
      },
    },
  };

  await cloudfront.createInvalidation(params).promise();
};

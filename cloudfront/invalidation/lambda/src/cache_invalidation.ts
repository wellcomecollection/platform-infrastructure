import { SNSHandler } from 'aws-lambda/trigger/sns';
import { CloudFront } from 'aws-sdk';
import { CreateInvalidationRequest } from 'aws-sdk/clients/cloudfront';

export const handler: SNSHandler = async (event) => {
  const distro = process.env.DISTRIBUTION_ID;

  const paths = JSON.parse(event.Records[0].Sns.Message);

  const cloudfront = new CloudFront();
  const params: CreateInvalidationRequest = {
    DistributionId: String(distro),
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

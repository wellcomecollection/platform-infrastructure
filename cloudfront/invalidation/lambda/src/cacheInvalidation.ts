import { SNSHandler, SNSEvent } from 'aws-lambda';
import { 
  CloudFrontClient, 
  CreateInvalidationCommand 
}  from '@aws-sdk/client-cloudfront'

export const handler: SNSHandler = async (event: SNSEvent) => {
  const cloudFrontClient = new CloudFrontClient();

  const distributionId = String(process.env.DISTRIBUTION_ID);
  const invalidationRequest = JSON.parse(event.Records[0].Sns.Message)
  
  const createInvalidationCommandInput = { 
    DistributionId: distributionId, 
    InvalidationBatch: { 
      Paths: { 
        Quantity: invalidationRequest.paths.length,
        Items: invalidationRequest.paths,
      },
      // we use the time (GMT) when the notification was published to identify the invalidation
      CallerReference: event.Records[0].Sns.Timestamp 
    },
  }

  const command = new CreateInvalidationCommand(createInvalidationCommandInput);
  await cloudFrontClient.send(command);  
};
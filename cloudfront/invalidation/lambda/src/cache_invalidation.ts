import { SNSHandler, SNSMessage } from 'aws-lambda/trigger/sns';
import * as AWS from 'aws-sdk';
import { CreateInvalidationRequest as CloudFrontInvalidationRequest } from 'aws-sdk/clients/cloudfront';

type IncomingMessage = {
  reference: string;
  paths: string[];
};

type InvalidationRequest = {
  distribution: string;
  reference: string;
  paths: string[];
};

function createCloudFrontRequest(
  invalidationRequest: InvalidationRequest
): CloudFrontInvalidationRequest {
  return {
    DistributionId: invalidationRequest.distribution,
    InvalidationBatch: {
      CallerReference: invalidationRequest.reference,
      Paths: {
        Quantity: invalidationRequest.paths.length,
        Items: invalidationRequest.paths,
      },
    },
  } as CloudFrontInvalidationRequest;
}

function createInvalidationRequest(
  distribution: string,
  message: SNSMessage
): InvalidationRequest {
  const incomingMessage = JSON.parse(message.Message) as IncomingMessage;
  return {
    distribution: distribution,
    reference: incomingMessage.reference,
    paths: incomingMessage.paths,
  } as InvalidationRequest;
}

function runInvalidation(
  cloudfront: AWS.CloudFront,
  invalidationRequest: InvalidationRequest
) {
  const cloudFrontRequest = createCloudFrontRequest(invalidationRequest);
  return cloudfront.createInvalidation(cloudFrontRequest).promise();
}

export const handler: SNSHandler = async (event) => {
  const distro = String(process.env.DISTRIBUTION_ID);
  const cloudfront = new AWS.CloudFront();
  const invalidationRequest = createInvalidationRequest(
    distro,
    event.Records[0].Sns
  );
  await runInvalidation(cloudfront, invalidationRequest);
};

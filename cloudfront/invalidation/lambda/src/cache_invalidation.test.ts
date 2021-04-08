import { expect, test } from '@jest/globals';
import { SNSEvent, SNSEventRecord } from 'aws-lambda/trigger/sns';
import { Context } from 'aws-lambda';
import * as AWS from "aws-sdk";
import { CreateInvalidationRequest as CloudFrontInvalidationRequest } from 'aws-sdk/clients/cloudfront';
import * as AWSMock from "aws-sdk-mock";

import { handler } from './cache_invalidation';

test('test request', async () => {
  const message = {
    paths: ["foo", "bar"],
    reference: "my-test-reference"
  };
  const fakeEvent = getFakeEvent(JSON.stringify(message));

  AWSMock.setSDKInstance(AWS);
  let called = false;
  AWSMock.mock("CloudFront", "createInvalidation", (params: CloudFrontInvalidationRequest, callback: Function) => {
    called = true;
    callback(null, null);
  })

  await handler(fakeEvent, {} as Context, () => {});
  expect(called).toBe(true);
});

function getFakeEvent(message: string): SNSEvent {
  return {
    Records: [
      {
        EventVersion: '1.0',
        EventSubscriptionArn:
          'arn:aws:sns:us-east-2:123456789012:sns-lambda:21be56ed-a058-49f5-8c98-aedd2564c486',
        EventSource: 'aws:sns',
        Sns: {
          SignatureVersion: '1',
          Timestamp: '2019-01-02T12:45:07.000Z',
          Signature:
            'tcc6faL2yUC6dgZdmrwh1Y4cGa/ebXEkAi6RibDsvpi+tE/1+82j...65r==',
          SigningCertUrl:
            'https://sns.us-east-2.amazonaws.com/SimpleNotificationService-ac565b8b1a6c5d002d285f9598aa1d9b.pem',
          MessageId: '95df01b4-ee98-5cb9-9903-4c221d41eb5e',
          Type: 'Notification',
          UnsubscribeUrl:
            'https://sns.us-east-2.amazonaws.com/?Action=Unsubscribe&amp;SubscriptionArn=arn:aws:sns:us-east-2:123456789012:test-lambda:21be56ed-a058-49f5-8c98-aedd2564c486',
          TopicArn: 'arn:aws:sns:us-east-2:123456789012:sns-lambda',
          Subject: 'TestInvoke',
          Message: message,
        },
      } as SNSEventRecord,
    ],
  } as SNSEvent;
}
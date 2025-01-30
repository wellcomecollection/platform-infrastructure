import { SNSEvent, Context } from 'aws-lambda';
import { CloudFrontClient }  from '@aws-sdk/client-cloudfront'
import { mockClient } from 'aws-sdk-client-mock';
import { handler } from './cacheInvalidation';

const timeStamp = new Date("2019-01-02T12:45:07.000Z").toISOString()

test('makes correct invalidation request', async () => {
  process.env = {
    DISTRIBUTION_ID: "Distro McDistrFace",
  };
  const message = {
    paths: ['/path/to/invalidate', '/path/with/wildcard*'],
  };
  const mockEvent = getMockEvent(JSON.stringify(message));

  const cloudFrontMock = mockClient(CloudFrontClient);

  const expectedInvalidationCommand = {
    DistributionId:  "Distro McDistrFace",
    InvalidationBatch: {
      Paths: { Quantity: message.paths.length, Items: message.paths },
      CallerReference: timeStamp
    }
  };

  await handler(mockEvent, {} as Context, () => {});
  expect(cloudFrontMock.call(0).args[0].input).toStrictEqual(expectedInvalidationCommand)
});

// note - this is boilerplate from aws docs
function getMockEvent(message: string): SNSEvent {
  return {
    "Records": [
      {
        "EventVersion": "1.0",
        "EventSubscriptionArn": "arn:aws:sns:us-east-1:123456789012:sns-lambda:21be56ed-a058-49f5-8c98-aedd2564c486",
        "EventSource": "aws:sns",
        "Sns": {
          "SignatureVersion": "1",
          "Timestamp": timeStamp,
          "Signature": "tcc6faL2yUC6dgZdmrwh1Y4cGa/ebXEkAi6RibDsvpi+tE/1+82j...65r==",
          "SigningCertUrl": "https://sns.us-east-1.amazonaws.com/SimpleNotificationService-ac565b8b1a6c5d002d285f9598aa1d9b.pem",
          "MessageId": "95df01b4-ee98-5cb9-9903-4c221d41eb5e",
          "Message": message,
          "MessageAttributes": {
            "Test": {
              "Type": "String",
              "Value": "TestString"
            },
            "TestBinary": {
              "Type": "Binary",
              "Value": "TestBinary"
            }
          },
          "Type": "Notification",
          "UnsubscribeUrl": "https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&amp;SubscriptionArn=arn:aws:sns:us-east-1:123456789012:test-lambda:21be56ed-a058-49f5-8c98-aedd2564c486",
          "TopicArn":"arn:aws:sns:us-east-1:123456789012:sns-lambda",
          "Subject": "TestInvoke"
        }
      }
    ]
  }
}
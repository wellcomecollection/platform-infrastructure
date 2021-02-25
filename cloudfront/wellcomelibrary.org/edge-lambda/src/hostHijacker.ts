import { CloudFrontRequest, CloudFrontRequestHandler } from 'aws-lambda';

export const requestHandler: CloudFrontRequestHandler = (
  event,
  context,
  callback
) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;
  request.headers['host'] = [{ key: 'host', value: 'wellcomelibrary.org' }];
  callback(null, request);
};

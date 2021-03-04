import { CloudFrontRequestHandler } from 'aws-lambda';
import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';

export const requestHandler: CloudFrontRequestHandler = (event, context, callback) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  request.headers['host'] = [{ key: 'host', value: 'wellcomelibrary.org' }];

  const fooUri: RegExp = /^\/foo\/.*/;

  const rewriteRequestUri: (uri: string) => string = (uri: string) => {
    if (uri.match(fooUri)) {
      return uri.replace('/foo', '/bar');
    } else {
      return uri;
    }
  };

  request.uri = rewriteRequestUri(request.uri);

  callback(null, request);
};

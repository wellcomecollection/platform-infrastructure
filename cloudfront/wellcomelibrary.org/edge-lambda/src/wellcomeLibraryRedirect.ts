import { CloudFrontRequestHandler } from 'aws-lambda';
import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';
import {redirect} from "./redirect";

export const requestHandler: CloudFrontRequestHandler = (event, context, callback) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  // Redirect www. -> to root
  if(request.headers.host && request.headers.host.length == 1) {
    const requestHost =  request.headers.host[0].value

    if (requestHost.startsWith('www.')) {
      const rootRequestHost = requestHost.replace('www.','');
      return Promise.resolve(redirect(`https://${rootRequestHost}${request.uri}`));
    }
  }

  request.headers['host'] = [{ key: 'host', value: 'wellcomelibrary.org' }];

  callback(null, request);
};

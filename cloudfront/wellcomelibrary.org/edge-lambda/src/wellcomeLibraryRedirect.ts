import {CloudFrontRequestEvent, CloudFrontRequestHandler, CloudFrontResultResponse, Context} from 'aws-lambda';
import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';
import axios from 'axios';
import {CloudFrontRequestResult} from "aws-lambda/trigger/cloudfront-request";


async function apiFetch(path: string) {
  return axios.get(
    'https://api.wellcomecollection.org/catalogue/v2' + path
  )
}

export const request = async (event: CloudFrontRequestEvent, _: Context) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  const fooUri: RegExp = /^\/foo\/.*/;

  const res = await apiFetch('/works/tsayk6g3');

  console.log(res.data)

  const rewriteRequestUri: (uri: string) => string = (uri: string) => {
    if (uri.match(fooUri)) {

      return uri.replace('/foo', '/bar');
    } else {
      return uri;
    }
  };

  request.uri = rewriteRequestUri(request.uri);

  return request;
};

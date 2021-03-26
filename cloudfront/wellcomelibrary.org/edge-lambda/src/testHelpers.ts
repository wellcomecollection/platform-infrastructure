import {
  CloudFrontRequest,
  CloudFrontResultResponse,
} from 'aws-lambda/common/cloudfront';
import { AxiosError, AxiosResponse } from 'axios';

export function expectedServerError(
  description: string
): CloudFrontResultResponse {
  return {
    status: '500',
    statusDescription: description,
  } as CloudFrontResultResponse;
}

export function expectedRedirect(uri: string): CloudFrontResultResponse {
  return {
    status: '302',
    statusDescription: `Redirecting to ${uri}`,
    headers: {
      location: [
        {
          key: 'Location',
          value: uri,
        },
      ],
      'access-control-allow-origin': [
        {
          key: 'Access-Control-Allow-Origin',
          value: '*',
        },
      ],
    },
  } as CloudFrontResultResponse;
}

export function expectedPassthru(uri: string): CloudFrontRequest {
  return {
    clientIp: '2001:cdba::3257:9652',
    headers: {
      host: [
        {
          key: 'host',
          value: 'wellcomelibrary.org',
        },
      ],
    },
    method: 'GET',
    querystring: '',
    uri: uri,
  } as CloudFrontRequest;
}

export const axios404 = {
  config: {},
  code: '404',
  request: {
    url: 'http://www.example.com',
  },
  response: {
    data: 'Not found',
    status: 404,
    statusText: 'Not found',
    headers: {},
    config: {},
  } as AxiosResponse,
} as AxiosError;

export const axiosNoResponse = {
  request: {
    url: 'http://www.example.com',
  },
  config: {},
} as AxiosError;

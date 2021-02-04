import {
    CloudFrontRequestHandler,
    CloudFrontResponseHandler,
} from 'aws-lambda';

export const request: CloudFrontRequestHandler = (event, context, callback) => {
    const request = event.Records[0].cf.request;

    callback(null, request);
};

export const response: CloudFrontResponseHandler = (
    event,
    context,
    callback
) => {
    const response = event.Records[0].cf.response;

    callback(null, response);
};

import {
    CloudFrontRequestHandler,
} from 'aws-lambda';

export const request: CloudFrontRequestHandler = (event, context, callback) => {
    const request = event.Records[0].cf.request;

    // This regex removes a starting "/image", and optionally a folllowing ".jpg" (with any case)
    request.uri = request.uri.replace(/^\/image\/([A-Za-z0-9]+)(?:\.[Jj][Pp][Gg])?(\/.*)/gm, '/$1$2')

    callback(null, request);
};
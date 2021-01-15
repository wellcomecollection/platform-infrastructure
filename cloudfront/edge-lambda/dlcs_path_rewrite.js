'use strict';

// lambda@edge Origin Request trigger to remove the first path element

exports.request = (event, context) => {
    const request = event.Records[0].cf.request;           // extract the request object
    request.uri = request.uri.replace(/^\/[^\/]+\//,'/');  // modify the URI
    return callback(null, request);                        // return control to CloudFront
};

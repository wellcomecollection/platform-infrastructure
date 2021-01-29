'use strict';

// lambda@edge Origin Request trigger to remove the first path element

exports.request = (event, context, callback) => {
    const request = event.Records[0].cf.request;           // extract the request object
    request.uri = request.uri.replace("/image/","/");      // remove leading /image/ from iiif URL
    request.uri = request.uri.replace(".jpg/","/");        // remove any non path terminating .jpg from iiif URL
    return callback(null, request);                        // return control to CloudFront
};

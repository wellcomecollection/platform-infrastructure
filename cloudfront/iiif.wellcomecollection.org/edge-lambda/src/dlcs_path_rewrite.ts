import {
    CloudFrontRequestHandler,
} from 'aws-lambda';
import {CloudFrontRequest} from "aws-lambda/common/cloudfront";

export const request: CloudFrontRequestHandler = (event, context, callback) => {
    const request: CloudFrontRequest = event.Records[0].cf.request;

    const newWellcomeImagesUri: RegExp = /^\/image\/[ABLNMSVW]00.+/
    const oldWellcomeImagesUri: RegExp = /^\/image\/[ABLNMSVW]00.+(?:\.jpg)\/.+/
    const dlcsImagesUri: RegExp = /^\/image\/.+/
    const dlcsAVUri: RegExp = /^\/av\/.+/
    const dlcsThumbsUri: RegExp = /^\/thumbs\/.+/
    const dlcsPdfUri: RegExp = /^\/pdf\/.+/
    const dlcsFileUri: RegExp = /^\/file\/.+/
    const dlcsAuth2Uri: RegExp = /^\/auth\/v2\/.+/
    const dlcsAuthUri: RegExp = /^\/auth\/.+/

    const rewriteRequestUri: (uri: string) => string = (uri: string) => {
        if(uri.match(oldWellcomeImagesUri)) {
            return uri
                .replace('/image', '')
                .replace('.jpg', '')
        } else if(uri.match(newWellcomeImagesUri)) {
            return uri
                .replace('/image', '')
        } else if(uri.match(dlcsImagesUri)) {
            return uri
                .replace('/image', '')
        } else if(uri.match(dlcsAVUri)) {
            return uri
                .replace('/av', '')
        } else if(uri.match(dlcsThumbsUri)) {
            return uri
                .replace('/thumbs', '')
        } else if(uri.match(dlcsPdfUri)) {
            return uri
                .replace('/pdf', '')
        } else if(uri.match(dlcsFileUri)) {
            return uri
                .replace('/file', '')
        } else if(uri.match(dlcsAuth2Uri)) {
            return uri
                .replace('/auth/v2/access', '')
                .replace('/auth/v2/probe', '')
        } else if(uri.match(dlcsAuthUri)) {
            return uri
                .replace('/auth', '')
        } else {
            return uri
        }
    }

    request.uri = rewriteRequestUri(request.uri)

    // This regex removes a starting "/image", and optionally a following ".jpg" (with any case)
    // request.uri = request.uri.replace(/^\/image\/([A-Za-z0-9]+)(?:\.[Jj][Pp][Gg])?(\/.*)/gm, '/$1$2')

    callback(null, request);
};
import {CloudFrontResultResponse} from "aws-lambda/common/cloudfront";

export async function redirect(uri: string){
    return {
        status: '301',
        statusDescription: `Redirecting to ${uri}`,
        headers: {
            location: [{
                key: 'Location',
                value: uri
            }]
        }
    } as CloudFrontResultResponse;
}
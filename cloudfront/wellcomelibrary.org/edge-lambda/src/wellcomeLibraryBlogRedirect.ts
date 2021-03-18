import {CloudFrontRequest} from "aws-lambda/common/cloudfront";
import {createRedirect} from "./redirectHelpers";
import {CloudFrontRequestEvent, Context} from "aws-lambda";

const blogHost = "https://blog.wellcomelibrary.org";
const waybackPrefix = "https://wayback.archive-it.org/16107-test/20210301160111/"

export function redirectToBlog(request: CloudFrontRequest) {
    if (request.headers.host?.length === 1) {
        const requestHost = request.headers.host[0].value;

        if (requestHost.startsWith('blog.')) {
            return createRedirect(
                new URL(`${waybackPrefix}${blogHost}${request.uri}`)
            );
        }
    }
}


export const requestHandler = async (
    event: CloudFrontRequestEvent,
    _: Context
) => {
    const request: CloudFrontRequest = event.Records[0].cf.request;

    const blogRedirect = redirectToBlog(request);
    if (blogRedirect) {
        return blogRedirect;
    }

    // If we've matched nothing so far then set the host header for Wellcome Library
    request.headers.host = [{ key: 'host', value: 'wellcomelibrary.org' }];

    return request;
};

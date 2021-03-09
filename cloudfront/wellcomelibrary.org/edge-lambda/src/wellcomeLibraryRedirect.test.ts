import * as origin from './wellcomeLibraryRedirect';
import testRequest from './testEventRequest';
import {Context} from 'aws-lambda';
import {CloudFrontResultResponse} from "aws-lambda/common/cloudfront";

function expectedRedirect(uri: string): CloudFrontResultResponse {
    return {
        status: '302',
        statusDescription: `Redirecting to ${uri}`,
        headers: {
            location: [{
                key: 'Location',
                value: uri
            }]
        }
    } as CloudFrontResultResponse;
}

test(`redirects www. to root`, () => {
    const requestCallback = jest.fn((_, request) => request);

    const request = testRequest('/foo', undefined, {
        host: [{key: 'host', value: 'www.wellcomelibrary.org'}],
    });

    const resultPromise = origin.requestHandler(request, {} as Context, requestCallback);

    return expect(resultPromise).resolves.toEqual(
        expectedRedirect('https://wellcomelibrary.org/foo')
    );
});

test(`rewrites the host header if it exists`, () => {
    const requestCallback = jest.fn((_, request) => request);
    const request = testRequest('/', undefined, {
        host: [{key: 'host', value: 'notwellcomelibrary.org'}],
    });

    origin.requestHandler(request, {} as Context, requestCallback);

    expect(request.Records[0].cf.request.headers).toStrictEqual({
        host: [{key: 'host', value: 'wellcomelibrary.org'}],
    });
});

test(`adds the host header if it is missing`, () => {
    const requestCallback = jest.fn((_, request) => request);
    const request = testRequest('/', undefined);

    origin.requestHandler(request, {} as Context, requestCallback);

    expect(request.Records[0].cf.request.headers).toStrictEqual({
        host: [{key: 'host', value: 'wellcomelibrary.org'}],
    });
});

test(`leaves other headers unmodified`, () => {
    const requestCallback = jest.fn((_, request) => request);
    const request = testRequest('/', undefined, {
        host: [{key: 'host', value: 'notwellcomelibrary.org'}],
        connection: [{key: 'connection', value: 'close'}],
        authorization: [
            {key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l'},
        ],
    });

    origin.requestHandler(request, {} as Context, requestCallback);

    expect(request.Records[0].cf.request.headers).toStrictEqual({
        host: [{key: 'host', value: 'wellcomelibrary.org'}],
        connection: [{key: 'connection', value: 'close'}],
        authorization: [
            {key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l'},
        ],
    });
});

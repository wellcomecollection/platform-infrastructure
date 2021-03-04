import * as origin from './wellcomeLibraryRedirect';
import testRequest from './testEventRequest';
import {Context} from 'aws-lambda';
import {testDataNoResults, testDataSingleResult} from './apiFixtures'
import axios from 'axios';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

type ExpectedRewrite = {
    in: string;
    out: string;
    data: any
}

const rewriteTests = (): Array<ExpectedRewrite> => {
    return [
        {
            in: '/item/b21293302',
            out: '/works/k2a8y7q6',
            data: testDataSingleResult
        },
        {
            in: '/item/b21293302',
            out: '/works/not-found',
            data: testDataNoResults
        },
        {
            in: '/not_item',
            out: '/not_item',
            data: {}
        },
        {
            in: '/item/not-bnumber',
            out: '/works/not-found',
            data: {}
        }
    ];
};


test.each(rewriteTests())(
    'Request path is rewritten: %o',
    async (expected: ExpectedRewrite) => {
        const request = testRequest(expected.in);

        if(expected.data) {
            mockedAxios.get.mockResolvedValueOnce({data: expected.data});
        }

        const originRequest = await origin.requestHandler(request, {} as Context)

        expect(originRequest.uri).toBe(expected.out);
    }
);

test(`rewrites the host header if it exists`, async () => {
    const request = testRequest('/', undefined, {
        host: [{ key: 'host', value: 'notwellcomelibrary.org' }],
    });

    const originRequest = await origin.requestHandler(request, {} as Context)

    expect(originRequest.headers).toStrictEqual({
        host: [{ key: 'host', value: 'wellcomelibrary.org' }],
    });
});

test(`adds the host header if it is missing`, async () => {
    const request = testRequest('/', undefined);

    const originRequest = await origin.requestHandler(request, {} as Context)

    expect(originRequest.headers).toStrictEqual({
        host: [{ key: 'host', value: 'wellcomelibrary.org' }],
    });
});

test(`leaves other headers unmodified`, async () => {
    const request = testRequest('/', undefined, {
        host: [{ key: 'host', value: 'notwellcomelibrary.org' }],
        connection: [{ key: 'connection', value: 'close' }],
        authorization: [
            { key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l' },
        ],
    });

    const originRequest = await origin.requestHandler(request, {} as Context)

    expect(originRequest.headers).toStrictEqual({
        host: [{ key: 'host', value: 'wellcomelibrary.org' }],
        connection: [{ key: 'connection', value: 'close' }],
        authorization: [
            { key: 'authorization', value: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l' },
        ],
    });
});

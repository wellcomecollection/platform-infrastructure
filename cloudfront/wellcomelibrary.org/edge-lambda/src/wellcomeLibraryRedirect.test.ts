import * as origin from './wellcomeLibraryRedirect';
import testRequest from './testEventRequest';
import {Context} from 'aws-lambda';

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
            data: {
                "@context": "https://api.wellcomecollection.org/catalogue/v2/context.json",
                "type": "ResultList",
                "pageSize": 10, totalPages: 1,
                "totalResults": 1,
                "results": [
                    {
                        "id": "k2a8y7q6",
                        "title": "Basic care of cats and kittens / The Cats Protection League.",
                        "alternativeTitles": [],
                        "description": "<p>Leaflet outlining basic training and health tips for people with a new kitten.</p>",
                        "physicalDescription": "1 folded sheet (4 p.) : ill. ; 21 cm.",
                        "workType": {},
                        "thumbnail": {},
                        "availableOnline": true,
                        "availabilities": {},
                        "type": "Work"
                    }
                ]
            }
        },
    ];
};


test.each(rewriteTests())(
    'Request path is rewritten: %o',
    async (expected: ExpectedRewrite) => {
        const event = testRequest(expected.in);

        if(expected.data) {
            mockedAxios.get.mockResolvedValueOnce({data: expected.data});
        }

        const originRequest = await origin.request(event, {} as Context)

        expect(originRequest.uri).toBe(expected.out);
    }
);

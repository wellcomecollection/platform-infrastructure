import axios from 'axios';
import {getWork} from "./api";
import {testDataNoResults, testDataSingleResult} from './apiFixtures'
import {Work} from "./catalogue";

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

test(`returns an Error when none available`, async () => {
    mockedAxios.get.mockResolvedValueOnce({data: testDataNoResults});

    const workResults = await getWork('bnumber')
    expect(workResults).toEqual(Error("No matching Catalogue API results found"))
});

test(`returns a Work when one result available`, async () => {
    mockedAxios.get.mockResolvedValueOnce({data: testDataSingleResult});

    const expectedWork = testDataSingleResult.results[0] as Work

    const workResults = await getWork('bnumber')
    expect(workResults).toEqual(expectedWork)
});
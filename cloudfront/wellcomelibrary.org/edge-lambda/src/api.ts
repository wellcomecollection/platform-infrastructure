import axios from "axios";
import {Work, CatalogueResultsList} from "./catalogue";

export type GetWorkResult = Work | Error

const apiBasePath = 'https://api.wellcomecollection.org/catalogue/v2'

type ApiQuery = {
    query: string[]
    include: Array<string>
}

async function* apiQuery(query: ApiQuery): AsyncGenerator<Work, void, void> {
    const url = apiBasePath + '/works';
    const config = { params: query }

    const apiResult = await axios.get(url, config);

    const resultList = apiResult.data as CatalogueResultsList

    // const nextPage = resultList.nextPage

    for(let i = 0; i < resultList.results.length; i++) {
        yield resultList.results[i];
    }
}

// TODO: Account for multiple results by looking for matching sierra entry
// TODO: Account for situations where results overflow page
export async function getWork(bNumber: string): Promise<GetWorkResult> {
    const resultList = apiQuery({
        query: bNumber,
        include: ['identifiers']
    })

    let result = await resultList.next();
    let work = undefined

    while(!result.done) {
        const current = result.value
        work = current

        result = await resultList.next()
    }

    if(work) {
        return work
    } else {
        return Error("No matching Catalogue API results found")
    }
}
import axios from "axios";
import {Work, CatalogueResultsList} from "./catalogue";

export type GetWorkResult = Work | Error

const apiBasePath = 'https://api.wellcomecollection.org/catalogue/v2'

type ApiQuery = {
    query: string
    include: Array<string>
}

async function* apiQuery(query: ApiQuery): AsyncGenerator<Work, void, void> {
    const url = apiBasePath + '/works';
    const apiResult = await axios.get(url, {params: query}  );

    const resultList = apiResult.data as CatalogueResultsList
    // const nextPage = resultList.nextPage
    //
    // if(resultList.results.length == 0) {
    //     return Error("No matching Catalogue API results found")
    // }

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

    while(result.done) {
        const current = result.value


        result = await resultList.next()
    }
    // const result = await resultList.next()
    // result.value
    //
    // if(!result.done){
    //     return result.value
    // } else {
    //     return Error("No matching Catalogue API results found")
    // }

    // if(resultList.results.length == 0) {
    //     return Error("No matching Catalogue API results found")
    // }
    //
    // return result.value
}
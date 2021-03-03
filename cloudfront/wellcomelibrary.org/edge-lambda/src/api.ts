import axios from "axios";
import {Work, CatalogueResultsList} from "./catalogue";

export type GetWorkResult = Work | Error

async function apiFetch(path: string) {
    return axios.get(
        'https://api.wellcomecollection.org/catalogue/v2' + path
    )
}

// TODO: Account for multiple results by looking for matching sierra entry
// TODO: Account for situations where results overflow page
export async function getWork(bNumber: string): Promise<GetWorkResult> {
    const apiPath = `/works?identifiers=${bNumber}`
    const results = await apiFetch(apiPath)

    const resultList = results.data as CatalogueResultsList

    if(resultList.results.length == 0) {
        return Error("No matching Catalogue API results found")
    }

    return resultList.results[0]
}
import {CloudFrontRequestEvent, CloudFrontRequestHandler, CloudFrontResultResponse, Context} from 'aws-lambda';
import { CloudFrontRequest } from 'aws-lambda/common/cloudfront';
import axios from 'axios';
import assert from "assert";
import { CatalogueResultsList } from './catalogue'

async function apiFetch(path: string) {
  return axios.get(
    'https://api.wellcomecollection.org/catalogue/v2' + path
  )
}

// TODO: Account for multiple results by looking for matching sierra entry
// TODO: Account for situations where results overflow page
async function getWork(bNumber: string) {
  const apiPath = `/works?identifiers=${bNumber}`
  const results = await apiFetch(apiPath)

  const resultList = results.data as CatalogueResultsList
  assert(resultList.results.length >= 1, "No matching Catalogue API results found")

  return resultList.results[0]
}

// TODO: Properly test for all these cases
function getBnumberFromPath(path: string) {
  const splitPath = path.split("/")
  const bNumberRegexp = /^b[0-9]{8}/

  assert(splitPath[0] == "", `Path ${path} does not start with /`)
  assert(splitPath[1] == "item", `Path ${path} does not start with /item`)
  assert(splitPath.length == 3, `Path ${path} has too many elements (expected 3)`)
  assert(bNumberRegexp.test(splitPath[2]), `b number in ${path} does not match ${bNumberRegexp}`)

  return splitPath[2]
}

// TODO: Catch/log/continue safely on assertion failures here
export const request = async (event: CloudFrontRequestEvent, _: Context) => {
  const request: CloudFrontRequest = event.Records[0].cf.request;

  const itemPathRegExp: RegExp = /^\/item\/.*/;

  async function rewriteRequestUri(uri: string) {
    if (uri.match(itemPathRegExp)) {
      const bNumber = getBnumberFromPath(uri)
      const work = await getWork(bNumber)

      return `/works/${work.id}`;
    } else {
      return uri;
    }
  };

  request.uri = await rewriteRequestUri(request.uri);

  return request;
};

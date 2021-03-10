// TODO: Account for multiple results by looking for matching sierra entry
import { apiQuery, GetWorkResult } from './api';

export async function getWork(bNumber: string): Promise<GetWorkResult> {
  const resultList = apiQuery({
    query: bNumber,
    include: ['identifiers'],
  });

  let work;

  for await (const result of resultList) {
    work = result;
  }

  if (work) {
    return work;
  } else {
    return Error('No matching Catalogue API results found');
  }
}

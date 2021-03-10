import axios from 'axios';

const apiBasePath = 'https://api.wellcomecollection.org/catalogue/v2';

type ApiQuery = {
  query: string;
  include: string[];
};

type IdentifierType = {
  id: string;
  label: string;
  type: 'IdentifierType';
};

type Identifier = {
  value: string;
  identifierType: IdentifierType;
  type: 'Identifier';
};

export type Work = {
  type: 'Work' | 'Collection' | 'Section' | 'Series';
  id: string;
  title: string;
  identifiers?: Identifier[];
};

export type CatalogueResultsList<Result = Work> = {
  type: 'ResultList';
  totalResults: number;
  results: Result[];
  pageSize: number;
  prevPage?: string;
  nextPage: string | undefined;
};

export type GetWorkResult = Work | Error;

export async function* apiQuery(
  query: ApiQuery
): AsyncGenerator<Work, void, void> {
  const url = `${apiBasePath}/works`;
  const config = { params: query };

  const apiResult = await axios.get(url, config);
  const resultList = apiResult.data as CatalogueResultsList;

  let nextPage = resultList.nextPage;
  for await (const result of resultList.results) {
    yield result;
  }

  while (nextPage) {
    const apiResult = await axios.get(nextPage);
    const resultList = apiResult.data as CatalogueResultsList;
    nextPage = resultList.nextPage;

    for await (const result of resultList.results) {
      yield result;
    }
  }
}

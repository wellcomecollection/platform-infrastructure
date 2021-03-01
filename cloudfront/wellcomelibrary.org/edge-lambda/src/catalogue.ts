export type Work = {
    type: 'Work' | 'Collection' | 'Section' | 'Series';
    id: string;
    title: string;
};

export type CatalogueResultsList<Result = Work> = {
    type: 'ResultList';
    totalResults: number;
    results: Result[];
    pageSize: number;
    prevPage: string | null;
    nextPage: string | null;
};
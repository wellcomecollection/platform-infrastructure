export const testDataSingleResult = {
  '@context': 'https://api.wellcomecollection.org/catalogue/v2/context.json',
  type: 'ResultList',
  pageSize: 10,
  totalPages: 1,
  totalResults: 1,
  results: [
    {
      id: 'k2a8y7q6',
      title: 'Basic care of cats and kittens / The Cats Protection League.',
      alternativeTitles: [],
      description:
        '<p>Leaflet outlining basic training and health tips for people with a new kitten.</p>',
      physicalDescription: '1 folded sheet (4 p.) : ill. ; 21 cm.',
      workType: {},
      identifiers: [
        {
          identifierType: {
            id: 'sierra-identifier',
            label: 'Sierra identifier',
            type: 'IdentifierType',
          },
          value: '2242512',
          type: 'Identifier',
        },
      ],
      thumbnail: {},
      availableOnline: true,
      availabilities: {},
      type: 'Work',
    },
  ],
};

export const testDataMultipleResults = {
  '@context': 'https://api.wellcomecollection.org/catalogue/v2/context.json',
  type: 'ResultList',
  pageSize: 10,
  totalPages: 1,
  totalResults: 2,
  results: [
    {
      id: 'k2a8y7q6',
      title: 'Basic care of cats and kittens / The Cats Protection League.',
      alternativeTitles: [],
      description:
        '<p>Leaflet outlining basic training and health tips for people with a new kitten.</p>',
      physicalDescription: '1 folded sheet (4 p.) : ill. ; 21 cm.',
      workType: {},
      identifiers: [
        {
          identifierType: {
            id: 'sierra-identifier',
            label: 'Sierra identifier',
            type: 'IdentifierType',
          },
          value: '2242512',
          type: 'Identifier',
        },
      ],
      thumbnail: {},
      availableOnline: true,
      availabilities: {},
      type: 'Work',
    },
    {
      id: 'pk2appa8',
      title: 'The remonstrance moved in the House of Commons',
      alternativeTitles: [],
      description: '<p>Large blue box containing seven human souls.</p>',
      physicalDescription: 'Large blue box, emits continuous screams.',
      workType: {},
      thumbnail: {},
      availableOnline: true,
      availabilities: {},
      type: 'Work',
    },
  ],
};

export const testDataMultiPageFirstPage = {
  '@context': 'https://api.wellcomecollection.org/catalogue/v2/context.json',
  type: 'ResultList',
  pageSize: 1,
  totalPages: 2,
  totalResults: 2,
  results: [
    {
      id: 'k2a8y7q6',
      title: 'Basic care of cats and kittens / The Cats Protection League.',
      alternativeTitles: [],
      description:
        '<p>Leaflet outlining basic training and health tips for people with a new kitten.</p>',
      physicalDescription: '1 folded sheet (4 p.) : ill. ; 21 cm.',
      workType: {},
      identifiers: [
        {
          identifierType: {
            id: 'sierra-identifier',
            label: 'Sierra identifier',
            type: 'IdentifierType',
          },
          value: '2242512',
          type: 'Identifier',
        },
      ],
      thumbnail: {},
      availableOnline: true,
      availabilities: {},
      type: 'Work',
    },
  ],
  nextPage:
    'https://api.wellcomecollection.org/catalogue/v2/works?include=identifiers&page=2&query=b12062789',
};

export const testDataMultiPageNextPage = {
  '@context': 'https://api.wellcomecollection.org/catalogue/v2/context.json',
  type: 'ResultList',
  pageSize: 1,
  totalPages: 2,
  totalResults: 2,
  results: [
    {
      id: 'pk2appa8',
      title: 'Box we found in the basement last Tuesday',
      alternativeTitles: [],
      description: '<p>Large blue box containing seven human souls.</p>',
      physicalDescription: 'Large blue box, emits continuous screams.',
      workType: {},
      thumbnail: {},
      availableOnline: false,
      availabilities: {},
      type: 'Work',
    },
  ],
  nextPage: undefined,
  prevPage:
    'https://api.wellcomecollection.org/catalogue/v2/works?include=identifiers&page=1&query=b12062789',
};

export const testDataNoResults = {
  '@context': 'https://api.wellcomecollection.org/catalogue/v2/context.json',
  type: 'ResultList',
  pageSize: 10,
  totalPages: 1,
  totalResults: 0,
  results: [],
};

export const testDataSingleResult = {
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
};

export const testDataMultiPageFirstPage = {
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
    ],
    "nextPage": "https://api.wellcomecollection.org/catalogue/v2/works?include=identifiers&page=2&query=b12062789"
};

export const testDataMultiPageNextPage = {
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
    ],
    "prevPage": "https://api.wellcomecollection.org/catalogue/v2/works?include=identifiers&page=1&query=b12062789"
};


export const testDataNoResults = {
    "@context": "https://api.wellcomecollection.org/catalogue/v2/context.json",
    "type": "ResultList",
    "pageSize": 10, totalPages: 1,
    "totalResults": 0,
    "results": []
};

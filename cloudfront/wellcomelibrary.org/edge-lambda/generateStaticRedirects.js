"use strict";
exports.__esModule = true;
exports.readStaticRedirects = void 0;
var csv = require("@fast-csv/parse");
var path = require("path");
// TODO: Consider pre-generating JSON in build step
function readStaticRedirects() {
    var fileLocation = path.resolve(__dirname, 'redirects.csv');
    var options = { skipLines: 1, headers: [undefined, 'libraryUrl', 'collectionUrl', undefined, undefined] };
    return new Promise(function (resolve, reject) {
        var redirects = {};
        csv.parseFile(fileLocation, options)
            .on("error", reject)
            .on("data", function (row) {
            var lookupKey = row.libraryUrl.replace('wellcomelibrary.org', '');
            redirects[lookupKey] = row.collectionUrl;
        })
            .on("end", function () {
            resolve(redirects);
        });
    });
}
exports.readStaticRedirects = readStaticRedirects;
console.log('foo');

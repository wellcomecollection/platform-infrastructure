# Redirection lambda

This Lambda has the business logic for redirecting pages from `wellcomelibrary.org` to the corresponding page on `wellcomecollection.org`.

For instructions on deploying the Lambda, see the top-level README.

## Rules for redirection

We have a couple of categories of "redirection rule":

-   **Static redirections.**
    Some pages have hard-coded redirects, configured in `staticRedirects.csv`.

    (This file is converted to JSON when it's packaged in the Lambda, but this happens automatically as part of the build process.)

-   **Identifier-based redirection.**
    When we see an identifier in the old URL, we look it up with the catalogue API to see if there's a corresponding Work page on the new site.

    e.g. if the old URL was `wellcomelibrary.org/item/b14657314`, we'd extract the `b14657314` identifier from the URL.
    We'd then query the catalogue API to learn that this has become work `th72q8u5`, and redirect the user to `wellcomecollection.org/works/th72q8u5`.

*   **Search-based redirection.**
    If the old URL looks like a search and we can extract a search term, we redirect the user to the Works search on the new site with the search term filled in the new query.

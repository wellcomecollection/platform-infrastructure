# Redirection lambda

This lambda redirects paths from wellcomelibrary.org to wellcomecollection.org as part of the decommissioning of the old Wellcome Library site.

There are a number of redirection patterns implemented here, including:

- Item page URLs
- Search URLs
- Catalogue URLs
- Archive URLs
- Static (content) redirects

## Static redirects

This folder contains the file [staticRedirects.csv](staticRedirects.csv), which lists the static redirects.

If you update the CSV you will need to run `yarn generateStaticRedirects` and commit the resulting `./src/staticRedirects.json`.
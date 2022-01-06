# wellcomelibrary.org

This is the CloudFront distribution for the old `wellcomelibrary.org` website.
It includes the code for redirecting users from the old site to the appropriate `wellcomecollection.org` URL.

## Key pieces

*   The CloudFront distributions are in the platform account.
    We have one distribution per subdomain of `wellcomelibrary.org` (e.g. `archives.wellcomelibrary.org`, `catalogue.wellcomelibrary.org`).

*   Each CloudFront distribution is connected to a Lambda@Edge function (defined in `edge-lambda`), which decides whether to redirect the user to the new site, or forward them to the old site.

    (We use Lambda@Edge instead of CloudFront Functions because we sometimes need to make HTTP requests before doing a redirect.
    e.g. looking up a b-number from a URL so we can find the appropriate works page.)

*   The Route 53 hosted zone for wellcomelibrary.org is defined in a D&T account.
    We create DNS records in that hosted zone that point to our CloudFront distributions.

## Key subdomains/services

*   `blog.wellcomelibrary.org` was the Wellcome Library blog.
    It's been backed up in the Wayback Machine by the Internet Archive, and we redirect requests to the archived version.

*   Encore was a web front-end for the library catalogue/Sierra, available at both `search.wellcomelibrary.org` and `wellcomelibrary.org` (no subdomain).
    As of January 2022, we are not redirecting Encore URLs.
    We will eventually redirect requests to the Works pages on the new website.

*   The OPAC ([online public access catalogue][opac]) was another web front-end for the library catalogue/Sierra, available at `catalogue.wellcomelibrary.org`.
    As of January 2022, we are not redirecting OPAC URLs, and we have no immediate plans to do so.

*   DServe was a web front-end for the archive catalogue/CALM, available at `archives.wellcomelibrary.org`.
    We redirect requests to the Works pages on the new website.

[opac]: https://en.wikipedia.org/wiki/Online_public_access_catalog

## AWS Route53

If you need access to the Route53 console use [this link](https://console.aws.amazon.com/route53/v2/hostedzones?#ListRecordSets/Z78J6G8RSOLSZ). You will need to have permissions to assume the role: `arn:aws:iam::267269328833:role/wellcomecollection-assume_role_hosted_zone_update`.

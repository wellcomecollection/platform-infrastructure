# Notes on the microsites account

The microsites account is an old AWS account that was run by a contractor we no longer use.
These sites included quiz.wellcomecollection.org and chorus.wellcomecollection.org.

At time of writing (27 January 2022), it only contained a few resources:

*   Some EC2 instances (terminated/stopped)
*   Some S3 buckets
*   A couple of RDS databases

There's nothing running in the account right now, because we don't know:

*   What's there
*   The underlying tech stack
*   How secure it is

In particular, we shut down the remaining applications during the Log4shell security incident in December 2021, because we couldn't assess whether they were vulnerable.

We are still responsible for the services in this account, and we should make sure they're archived appropriately, but we have no plans to re-enable them.

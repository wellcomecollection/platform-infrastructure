# accounts

This directory contains the config for our AWS accounts.
We use multiple accounts within an [AWS Organisation], which provides a coarse level of isolation between different services.

Within each account, we create a standard set of roles.
Each role has different permissions, allowing us to apply the [principle of least privilege][privilege] when working in accounts – we can select the least powerful role for a given task.

We log into AWS using Azure AD and single sign-on.
This includes getting AWS CLI credentials.

[AWS Organisation]: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts.html
[privilege]: https://en.wikipedia.org/wiki/Principle_of_least_privilege



## Our accounts

<table id="accounts">
  <tr>
    <th>Account name</th>
    <th>Account ID</th>
    <th>What it&rsquo;s used for</th>
  </tr>
  <tr>
    <td>platform</td>
    <td>760097843905</td>
    <td>
      Our original AWS account.
      Used for infrastructure shared across the platform, and some resources that predate the use of separate accounts.
    </td>
  </tr>
  <tr>
    <td>catalogue</td>
    <td>756629837203</td>
    <td>
      The catalogue API.
      Ideally it would have the rest of the catalogue services (e.g. pipeline, adapter), but they were created before this account.
    </td>
  </tr>
  <tr>
    <td>data</td>
    <td>964279923020</td>
    <td>Data science-related services.</td>
  </tr>
  <tr>
    <td>digirati</td>
    <td>653428163053</td>
    <td>All the Digirati services, including DLCS and iiif-builder.</td>
  </tr>
  <tr>
    <td>digitisation</td>
    <td>404315009621</td>
    <td>Some S3 buckets used by the Digital Production team.</td>
  </tr>
  <tr>
    <td>experience</td>
    <td>130871440101</td>
    <td>
      The front-end web apps for wellcomecollection.org.
    </td>
  </tr>
  <tr>
    <td>identity</td>
    <td>770700576653</td>
    <td>
      This includes all the services for library account management.
      These services touch personally identifiable information (PII), so we&rsquo;re a bit more careful about who can access this account.
    </td>
  </tr>
  <tr>
    <td>reporting</td>
    <td>269807742353</td>
    <td>
      Services for populating the reporting cluster.
    </td>
  </tr>
  <tr>
    <td>storage</td>
    <td>975596993436</td>
    <td>
      The storage service, including both the permanent S3 buckets and the transient services.
    </td>
  </tr>
  <tr>
    <td>workflow</td>
    <td>299497370133</td>
    <td>Goobi and Archivematica.</td>
  </tr>

  <tr>
    <td>dam_prototype</td>
    <td>241906670800</td>
    <td>
      An empty account used for testing the storage service demo.
    </td>
  </tr>
  <tr>
    <td>microsites</td>
    <td>782179017633</td>
    <td>
      An old account with some microsites.
      This predates the platform, and you can&rsquo;t access it using our role-based infrastructure.
      See <a href="./docs/microsites.md">notes on the microsites account</a>.
    </td>
  </tr>
</table>

There's a list of all of Wellcome's AWS account in the [Wellcome Trust Confluence](https://wellcometrust.atlassian.net/wiki/spaces/INF/pages/719618052/AWS+Account+List).

## Standard roles

Within each account (except microsites), we create a standard set of roles:

<table id="roles">
  <tr>
    <th>role suffix</th>
    <th>example role</th>
    <th>what it allows</th>
  </tr>
  <tr>
    <td>admin</td>
    <td>workflow-admin</td>
    <td>
      Complete access to the account.
    </td>
  </tr>
  <tr>
    <td>developer</td>
    <td>platform-developer</td>
    <td>
      Complete access, bar a handful of destructive actions (e.g. deleting S3 buckets).
      This also doesn&rsquo;t allow configuring IAM users.
    </td>
  </tr>
  <tr>
    <td>billing</td>
    <td>experience-billing</td>
    <td>
      Provides access to billing information.
    </td>
  </tr>
  <tr>
    <td>ci</td>
    <td>identity-ci</td>
    <td>
      Provides the permissions that CI needs to do things in this account (e.g. publishing Docker images to ECR).
      Usually used by CI instances only.
    </td>
  </tr>
  <tr>
    <td>read_only</td>
    <td>digitisation-read_only</td>
    <td>
      Provides read-only access to most of the account.
      This doesn't include access to secrets in Secrets Manager.
    </td>
  </tr>
  <tr>
    <td>monitoring</td>
    <td>storage-monitoring</td>
    <td>
      Provides read-only access to some information about billing and ECS.
      (TODO: Do we still use/need this role?)
    </td>
  </tr>
  <tr>
    <td>publisher</td>
    <td>catalogue-publisher</td>
    <td>
      Allows publishing images into ECR.
      (TODO: Do we still use/need this role?)
    </td>
  </tr>
</table>

## How we log into these accounts

We log into these accounts using Azure Active Directory and SSO, although we don't use our standard network accounts – we use special `c_` accounts (e.g. `c_chana@wellcome.ac.uk`).

When you log into an account through SSO, you initially assume a role in the platform account, e.g.

```
platform-superdev/c_chana@wellcome.ac.uk
```

This role can't do anything by itself, except assume other roles.
You have to assume the account and role you actually want to use before you can do anything useful.

## Who gets access to what

In general, all developers have access to every account.
Most of the accounts don't contain any sensitive information, so the convenience outweighs the slight additional risk.

The main exception is the identity account.
The services in this account use [personally identifiable information (PII)][pii] via the Sierra API and Auth0, so we're a bit more careful about who can access this account.
Only developers working on identity-related services should have access to this account.

Non-developers may have access to specific accounts.
e.g. some of the Digital Production team have access to the S3 buckets in the digitisation and workflow accounts.

[pii]: https://en.wikipedia.org/wiki/Personal_data

## How to

*   [Log into an account using the AWS console](docs/console-login.md)

*   [Get credentials for the AWS CLI/local SDK](docs/cli-credentials.md)

*   [Select a role when working on the AWS CLI](docs/cli-roles.md)

*   To give/revoke somebody's permission to access our AWS accounts, you need to use the Azure blade and talk to D&T.
    The link to the blade is in [our private docs](https://github.com/wellcomecollection/private-docs/blob/main/account-config.md); you may need to go through CAB or D&T service desk.

    Assume this will take longer than you think, [and then some](https://en.wikipedia.org/wiki/Hofstadter%27s_law).

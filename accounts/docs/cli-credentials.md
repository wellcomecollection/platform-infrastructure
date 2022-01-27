# How to get credentials for the AWS CLI/local SDK

Developers can get short-lived credentials for working locally (lasting up to 4 hours).
This is meant to reduce the risk profile of lost secrets; e.g. if a laptop is stolen, it's less likely to have useful AWS credentials than if we all had long-lived, permanent credentials.

You need to intercept credentials from the SAML sign-in process.

1.  Install the Node app [sportradar/aws-azure-login](https://github.com/sportradar/aws-azure-login):

    ```console
    $ npm install -g aws-azure-login
    ```

2.  Configure the app:

    ```console
    $ aws-azure-login --configure
    Configuring profile 'default'
    ? Azure Tenant ID: [redacted]
    ? Azure App ID URI: [redacted]
    ? Default Username: [c_cloud email address]
    ? Stay logged in: skip authentication while refreshing aws credentials (true|false) false
    ? Default Role ARN (if multiple):
    ? Default Session Duration Hours (up to 12): 4
    Profile saved.
    ```

    Alternatively, add the following config to your `~/.aws/config` file:

    ```ini
    [default]
    region=eu-west-1
    azure_tenant_id=[redacted]
    azure_app_id_uri=[redacted]
    azure_default_username=[c_cloud email address]
    azure_default_role_arn=
    azure_default_duration_hours=4
    azure_default_remember_me=false
    ```

    You can get the Azure tenant/app ID by asking another developer, or reading our [private docs](https://github.com/wellcomecollection/private-docs/blob/main/account-config.md).

    Use your `c_` cloud email address as your Azure username, e.g. `c_chana@wellcome.ac.uk`.

3.  Once you have the app installed, run `aws-azure-login` and follow the prompts to get a new set of credentials, e.g.

    ```console
    $ aws-azure-login
    Logging in with profile 'default'...
    Using AWS SAML endpoint https://signin.aws.amazon.com/saml
    ? Username: c_chana@wellcome.ac.uk
    ? Password: [hidden]
    Open your Microsoft Authenticator app and approve the request to sign in.
    ? Session Duration Hours (up to 12): 4
    Assuming role arn:aws:iam::760097843905:role/platform-superdev
    ```


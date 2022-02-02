# How to select a role when working on the AWS CLI

Once you have [CLI credentials](./cli-credentials.md), you need to configure the roles you want to use in `~/.aws/credentials`.

1.  Append the contents of `credentials.ini` to your `~/.aws/credentials` file.

    This contains a list of [named profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html), e.g. a profile for the read-only role in the platform account:

    ```ini
    [platform-read_only]
    source_profile=default
    role_arn=arn:aws:iam::760097843905:role/platform-read_only
    region=eu-west-1
    ```

    The list is generated automatically by the `create_cli_roles.py`.

2.  To select a role, pass the `AWS_PROFILE` environment variable with the name of the profile.

    For example, these S3 commands will run in the platform, catalogue, and workflow accounts, respectively:

    ```console
    $ AWS_PROFILE=platform-read_only aws s3 ls

    $ AWS_PROFILE=catalogue-developer aws s3 ls

    $ AWS_PROFILE=workflow-admin aws s3 ls
    ```

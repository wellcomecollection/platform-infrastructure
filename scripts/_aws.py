import boto3


ACCOUNT_IDS = {
    "platform": "760097843905",
    "storage": "975596993436",
    "catalogue": "756629837203",
}


sts_client = boto3.client("sts")


def get_aws_client(resource, *, role_arn):
    assumed_role_object = sts_client.assume_role(
        RoleArn=role_arn, RoleSessionName="AssumeRoleSession1"
    )
    credentials = assumed_role_object["Credentials"]
    return boto3.client(
        resource,
        aws_access_key_id=credentials["AccessKeyId"],
        aws_secret_access_key=credentials["SecretAccessKey"],
        aws_session_token=credentials["SessionToken"],
    )


def get_s3_object(s3_client, *, bucket, key):
    """
    Retrieve the contents of an object from S3.
    """
    return s3_client.get_object(Bucket=bucket, Key=key)["Body"].read()

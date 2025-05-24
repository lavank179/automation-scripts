from botocore.config import Config
import boto3
import os

def get_aws_client(creds, service):
    return boto3.client(
        service,
        region_name="us-west-2",
        aws_access_key_id=creds["AWS_ACCESS_KEY_ID"],
        aws_secret_access_key=creds["AWS_SECRET_ACCESS_KEY"],
        config = Config(
            retries = {
                'max_attempts': 10,
                'mode': 'standard'
            }
        )
    )

def assume_role(sts, role_arn):
    try:
        return sts.assume_role(
            RoleArn=role_arn,
            RoleSessionName='TempSession'
        )
    except Exception as e:
        raise ValueError ("Error getting keys: {0}".format(e))

def get_sts_token(role_to_assume):
    creds = {
        "AWS_ACCESS_KEY_ID": os.environ["access_key"],
        "AWS_SECRET_ACCESS_KEY": os.environ["secret_key"]
    }
    sts = get_aws_client(creds, "sts")
    result = assume_role(sts, role_to_assume)
    return result


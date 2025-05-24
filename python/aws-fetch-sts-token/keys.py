import getpass
from cryptography.fernet import Fernet
import requests
import configparser
import os
from os.path import expanduser
import sys
import json

# key = Fernet.generate_key()
# print(key.decode())
key = b"<GENERATE_ONE_KEY_USING_ABOVE>"
fernet = Fernet(key)
# ----------------------------------------------------------------------------------------------------------


def store_token_to_aws_configure(result):
    awsconfigfile = "~/.aws/credentials"
    awsprofile = os.environ.get("AWS_PROFILE", "default")
    filename = expanduser(awsconfigfile)

    # Create .aws folder if not exists
    awsdirectory = os.path.dirname(filename)
    if not os.path.exists(awsdirectory):
        os.makedirs(awsdirectory)

    # Read in the existing config file
    config = configparser.RawConfigParser()
    # Put the credentials into a saml specific section instead of clobbering the default credentials
    if not (config.has_section(awsprofile)):
        config.add_section(awsprofile)

    config.set(awsprofile, "output", "json")
    config.set(awsprofile, "region", region)
    config.set(awsprofile, "aws_access_key_id", result["AccessKeyId"])
    config.set(awsprofile, "aws_secret_access_key", result["SecretAccessKey"])
    config.set(awsprofile, "aws_session_token", result["SessionToken"])

    # Write the updated config file
    with open(filename, "w+") as configfile:
        config.write(configfile)

    print("\n----------------------------------------------------------------")
    print("Your new access key pair has been stored in the AWS configuration file " + format(filename) + " under the " + awsprofile + " profile.")
    print("Note that it will expire at {0}.".format(result["Expiration"]))
    print("To use this credential, call the AWS CLI with the --profile option (e.g. aws --profile " + awsprofile + " ec2 describe-instances).")
    print("----------------------------------------------------------------\n")
    sys.stdout.flush()
    return


# ----------------------------------------------------------------------------------------------------------

print("Welcome to aws sts token generator client!")
print("Enter the credentials.")
real_raw_input = vars(__builtins__).get("raw_input", input)
login_creds = {"username": real_raw_input("Username: "), "password": getpass.getpass()}
region = real_raw_input("Region: ")
save_to_file = real_raw_input("Save_to_file ?(yes/no): ")
region = "us-west-2"

# Encrypt each field
encrypted_payload = {
    "username": fernet.encrypt(login_creds["username"].encode()).decode(),
    "password": fernet.encrypt(login_creds["password"].encode()).decode(),
    "region": region,
    "IsEncrypted": "true",
    "role_to_assume": ""
}

# ----------------------------------------------------------------------------------------------------------
url = "http://localhost:5000/sts-token"
# Send encrypted payload
response = requests.post(url,json=encrypted_payload,headers={"Content-Type": "application/json",},)
try:
    if (response.status_code!=200):
        error={ "status_code": response.status_code, "text": response.text }
        raise Exception (error)
    response = response.json()
    if "Credentials" in response:
        if save_to_file == "yes":
            store_token_to_aws_configure(response["Credentials"])
            print("Yay! you have successfully generated an aws sts temp token using python token gen.")
        else:
            print(response["AssumedRoleUser"])
            print("Yay! you have successfully generated an aws sts temp token using python token gen.")
    else:
        print("Server didn't return proper token data.")
except Exception as e:
    print("FAILED: Server not available or returned bad response.")
    print(f"ERROR: {e.args[0]}")

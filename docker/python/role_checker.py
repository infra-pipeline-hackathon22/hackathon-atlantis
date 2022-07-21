#!/usr/bin/env python3

from time import strftime
from typing import Dict, List
import boto3
import os
import sys
import argparse

parser = argparse.ArgumentParser(description='Check role for user')
parser.add_argument('--user', type=str )
parser.add_argument('--desired_role', type=str)
parser.add_argument('--mode', type=str, default="check")
args = parser.parse_args()

def get_available_roles(user: str) -> List[Dict[str,str]]:
    # FIXME: update this with actual roles that can be assumed by user
    iam_client = boto3.client('iam')
    response = iam_client.list_roles()
    roles = (response['Roles'])
    # print('roles found: ' + str(len(roles)))  
    return [{"name":role['RoleName'], "arn":role['Arn']} for role in roles]

def check_desired_role(user: str, desired_role: str) -> bool:
    roles = get_available_roles(user=user)
    return desired_role in [role['name'] for role in roles]

def get_desired_role(user: str, desired_role: str) -> Dict[str,str]:
    roles = get_available_roles(user=user)
    candidate_roles = list(filter(lambda role: desired_role in role['name'], roles))
    return candidate_roles[0]

can_access_desired_role = check_desired_role(user=args.user, desired_role=args.desired_role)
if not can_access_desired_role:
    if args.mode == "check":
        print("Invalid role.\n  Available roles are:\n {}".format('\n'.join([role['name'] for role in get_available_roles(user=args.user)])))
    sys.exit(1)

if args.mode == "print_arn":
    print(f"{get_desired_role(user=args.user, desired_role=args.desired_role)['arn']}")


def list_all_buckets_example():
    client = boto3.client('sts')
    assumed_role_object=client.assume_role(RoleArn="arn:aws:iam::240508968475:role/atlantis/test-readwrite", RoleSessionName="mys3role")
    # From the response that contains the assumed role, get the temporary 
    # credentials that can be used to make subsequent API calls
    credentials=assumed_role_object['Credentials']

    # Use the temporary credentials that AssumeRole returns to make a 
    # connection to Amazon S3  
    s3_resource=boto3.resource(
        's3',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken'],
    )

    # Use the Amazon S3 resource object that is now configured with the 
    # credentials to access your S3 buckets. 
    for bucket in s3_resource.buckets.all():
        print(bucket.name)
#!/usr/bin/env python3

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
    iam_client = boto3.client('iam')
    response = iam_client.list_roles()
    roles = (response['Roles'])
    print('roles found: ' + str(len(roles)))  
    return [{"role":role['RoleName'], "arn":role['Arn']} for role in roles]

def check_desired_role(user: str, desired_role: str) -> str:
    roles = get_available_roles(user=user)
    return roles[0]['role']
        
    # iam_client = boto3.client('iam')
    # response = iam_client.list_roles()
    # roles = (response['Roles'])
    # print('roles found: ' + str(len(roles)))  
    # for role in roles:
    #     print(role['RoleName'])
    #     print(role['Arn'])

if args.mode == "check":
    if not check_desired_role(user=args.user, desired_role=args.desired_role):
        print("Invalid role.\n  Available roles are: {'\n'.join([role['role'] for role in get_available_roles(user=user)])}")
        sys.exit(1)
else:
    print ("NYI")
    # print_checked_role(user=args.user, desired_role=args.desired_role)


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
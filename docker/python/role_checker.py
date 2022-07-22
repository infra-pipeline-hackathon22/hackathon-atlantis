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
# effectively exclude nothing by default as = can't be in environment name
parser.add_argument('--env_exclude', type=str, default="=") 
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

def get_desired_role_info(user: str, desired_role: str) -> Dict[str,str]:
    roles = get_available_roles(user=user)
    candidate_roles = list(filter(lambda role: desired_role in role['name'], roles))
    return candidate_roles[0]

def get_env_for_role(desired_role_arn:str)->Dict[str,str]:
    client = boto3.client('sts')
    # return {
    #     "AWS_ACCESS_KEY_ID":"foo",
    #     "AWS_SECRET_ACCESS_KEY":"bar",
    #     "AWS_SESSION_TOKEN":"baz"
    # }
    assumed_role_object=client.assume_role(RoleArn=desired_role_arn, RoleSessionName="mys3role")
    # From the response that contains the assumed role, get the temporary 
    # credentials that can be used to make subsequent API calls
    credentials=assumed_role_object['Credentials']

    return {
        "AWS_ACCESS_KEY_ID":credentials['AccessKeyId'],
        "AWS_SECRET_ACCESS_KEY":credentials['SecretAccessKey'],
        "AWS_SESSION_TOKEN":credentials['SessionToken']
    }


def main():
    user = args.user
    desired_role = args.desired_role.replace('\\','')

    can_access_desired_role = check_desired_role(user=user, desired_role=desired_role)
    if not can_access_desired_role:
        if args.mode == "check":
            print("Could not find matching role for: {0}.\n\nAvailable roles are:\n{1}".format(desired_role, '\n'.join([role['name'] for role in get_available_roles(user=user)])))
        sys.exit(1)

    desired_role_arn = get_desired_role_info(user=user, desired_role=desired_role)['arn']
    if args.mode == "print_arn":
        print(f"{desired_role_arn}")

    if "env" in args.mode:
        excluded_env_vars=args.env_exclude.split(",")
        filter_env_dict=dict(filter(lambda item: item[0] not in excluded_env_vars, get_env_for_role(desired_role_arn=desired_role_arn).items()))
        if args.mode == "env":
            print(','.join([f'{k}={v}' for k,v in filter_env_dict.items()]), end='')
        elif args.mode == "env_values":
            print(','.join([f'{v}' for v in filter_env_dict.values()]), end='')
    
if __name__ == "__main__":
    main()
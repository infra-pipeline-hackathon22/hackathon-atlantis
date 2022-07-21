#!/usr/bin/env python

import json
import os

f = open("roles.json")
data = json.load(f)
#atlantis apply -- admin
user_name = os.environ.get('USER_NAME')
args = os.environ.get('COMMENT_ARGS').split(',')
role, *rest = args

if role not in data.get(user_name):
    raise Exception(f"You don't have the role: ${role}")

print("Authenticated")
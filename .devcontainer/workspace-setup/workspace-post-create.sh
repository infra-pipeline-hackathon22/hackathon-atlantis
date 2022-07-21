#!/bin/bash

set -euo pipefail

WORKSPACE_FOLDER=${1}
SSO_PROFILE=${2}

rsync -a .devcontainer/workspace-setup/ ${WORKSPACE_FOLDER}/.vscode/ --ignore-existing

echo "Logging into AWS SSO with profile ${SSO_PROFILE}"
aws sso login --profile ${SSO_PROFILE}

#sudo pip install -r requirements.txt
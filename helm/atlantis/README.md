# Installing Atlantis

_All commands are run from within this directory_

## Prereqs

1. Ensure you have an `alb` ingress class
1. Create a namespace for atlantis to run in (i.e. `atlantis`)
1. Determine the role that atlantis should have a create a service account in the atlantis directory (e.g. `ATLANTIS_ROLE_ARN`)
```
ATLANTIS_NAMESPACE="atlantis"
CLUSTER_NAME="burner-dev"
ATLANTIS_ROLE_ARN="arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>"
eksctl create iamserviceaccount \
    --name atlantis \
    --namespace ${ATLANTIS_NAMESPACE} \
    --cluster ${CLUSTER_NAME} \
    --attach-role-arn "${ATLANTIS_ROLE_ARN}" \
    --approve \
    --override-existing-serviceaccounts
```
4. Add the atlantis repo

```
helm repo add runatlantis https://runatlantis.github.io/helm-charts
```

## Install

1. Set the following sensitive environment variables in your environment

```
KEY_FILE="<LOCATION TO PEM FOR GITHUB APP>"
GITHUB_APP_ID="<REPLACE WITH GITHUB APP ID>"
GITHUB_SECRET="<REPLACE WITH GITHUB SECRET>"
```

2. Run the following command from the command line

```
helm install atlantis runatlantis/atlantis \
    --set githubApp.key="$(cat $KEY_FILE)" \ 
    --set githubApp.id="${GITHUB_APP_ID}" \
    --set githubApp.secret="${GITHUB_SECRET}" -f values.yaml
```
3. Determine the name of your provisioned loadbalancer
```
LOAD_BALANCER="<DNS_NAME_OF_LOADBALANCER>"
```
4. Update values with load balancer (see below for how to do it with `--set` but you're better off updating your .yaml)
```
helm upgrade --reuse-values atlantis runatlantis/atlantis \
    --set atlantisUrl="http://${LOAD_BALANCER}" \
    --set ingress.host="${LOAD_BALANCER}" \
    --set githubApp.key="$(cat $KEY_FILE)" \ 
    --set githubApp.id="${GITHUB_APP_ID}" \
    --set githubApp.secret="${GITHUB_SECRET}" -f values.yaml
```
5. NOTE: when updating values you can run this (when updating sensitive vars you can use `--set` as you see below)

```
helm upgrade --reuse-values atlantis runatlantis/atlantis \
    --set githubApp.key="$(cat $KEY_FILE)" \ 
    --set githubApp.id="${GITHUB_APP_ID}" \
    --set githubApp.secret="${GITHUB_SECRET}" -f values.yaml
```
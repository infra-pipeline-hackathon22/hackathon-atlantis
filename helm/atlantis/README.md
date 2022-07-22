# Installing Atlantis

_All commands are run from within this directory_

## Prereqs

1. Ensure you have an `alb` ingress class
2. Create a namespace for atlantis
3. Determine the role that atlantis should have a create a service account in the atlantis directory

```
ATLANTIS_NAMESPACE="atlantis"
CLUSTER_NAME="burner-dev"
ATLANTIS_POLICY_ARN="arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>"
eksctl create iamserviceaccount \
    --name atlantis \
    --namespace ${ATLANTIS_NAMESPACE} \
    --cluster ${CLUSTER_NAME} \
    --attach-role-arn "${ATLANTIS_POLICY_ARN}" \
    --approve \
    --override-existing-serviceaccounts
```
3. Add the atlantis repo

```
helm repo add runatlantis https://runatlantis.github.io/helm-charts
```

## Install

3. Set the following sensitive environment variables in your environment

```

```

4. Run the following command from the command line

```
helm install atlantis runatlantis/atlantis -f values.yaml
```
. Determine the name of your provisioned loadbalancer
. Update values with 
5. NOTE: when updating values you can run this instead

```
helm upgrade --reuse-values atlantis runatlantis/atlantis --set githubApp.key="$(cat $KEY_FILE)" --set githubApp.id="${GITHUB_APP_ID}" --set githubApp.secret="${GITHUB_SECRET}" -f values.yaml
```
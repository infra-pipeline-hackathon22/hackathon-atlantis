# <a name="setup">Setup</a> PoC Infrastructure

These instructions work best when using a Burner Account and running within a VSCode devcontainer.

```sh
cd $REPO_HOME/terragrunt/config/canva
aws sso login
terragrunt run-all apply --terragrunt-non-interactive
```

Should eventually print something like

```

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

argocd_admin_password = "hunter2"
argocd_endpoint = "https://k8s-argocd-argocdar-deadbeef-cafe.elb.us-west-2.amazonaws.com"
```

## `kubectl` setup

If after issuing a `kubectl` command you see:

```
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

It might be that your .kube/config file is out of date.  You can run the following to refresh it:

```
CLUSTER_NAME=burner-dev
aws eks update-kubeconfig --name ${CLUSTER_NAME} 
```

## Accessing kubernetes dashboard

After the kubernetes terraform has been applied, you can log into the dashboard using the token for the `eks-admin` service account

1. First setup a proxy to the cluster (NOTE: requires your kube/config to be setup)
```
kubectl proxy
```
2. Now the dashboard should be available [here](http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/cluster?namespace=kubenetes-dashboard)
```
http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/cluster?namespace=kubenetes-dashboard
```
3. When prompted to login to the Kubernetes Dashboard, choose the Token option
![Dashboard login](../docs/dashboard_signin.png)
1. You can get the token for the service account by running the following and copying and pasting: 
```
kubectl -n kube-system get secret $(kubectl -n kube-system get sa/eks-admin -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

## Troubleshooting

### State Lock / LoadBalancer provisioning delays

While running terragrunt, if you experience the following error:

```
Acquiring state lock. This may take a few moments...

│ Error: Search returned 0 results, please revise so only one is returned
│ 
│   with data.aws_lb.argocd,
│   on main.tf line 8, in data "aws_lb" "argocd":
│    8: data "aws_lb" "argocd" {
│ 
│ Error: Search returned 0 results, please revise so only one is returned
│ 
│   with data.aws_lb.argo_rollouts,
│   on main.tf line 16, in data "aws_lb" "argo_rollouts":
│   16: data "aws_lb" "argo_rollouts" {

```

It means the LBs haven't finished provisioning yet. Wait for them to become active:

```sh
aws --region us-west-2 elbv2 describe-load-balancers | grep Code
```

before running terragrunt again. 

### Required Plugins not installed

If you see:

```
╷
│ Error: Required plugins are not installed
│ 
│ The installed provider plugins are not consistent with the packages
│ selected in the dependency lock file:
│   - registry.terraform.io/hashicorp/http: there is no package for registry.terraform.io/hashicorp/http 2.2.0 cached in .terraform/providers
│   - registry.terraform.io/hashicorp/cloudinit: there is no package for registry.terraform.io/hashicorp/cloudinit 2.2.0 cached in .terraform/providers
│   - registry.terraform.io/hashicorp/tls: there is no package for registry.terraform.io/hashicorp/tls 3.4.0 cached in .terraform/providers
...
```

Then it may be that your initialization got interrupted or out of sync.  Try running:

```
cd terragrunt/config/canva
terragrunt run-all init --terragrunt-non-interactive
```

If this completes successfully, you should see:

```
Terraform has been successfully initialized!

...
```

Then reattempt the `terragrunt run-all apply` in [Setup](#setup)



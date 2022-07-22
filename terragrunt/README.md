# Setup PoC Infrastructure

These instructions work best when using a Burner Account and running within a VSCode devcontainer.

```sh
cd $REPO_HOME/terragrunt/config/canva
aws sso login
terragrunt run-all apply --terragrunt-non-interactive
```
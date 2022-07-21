#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM python:3.9

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Or your actual UID, GID on Linux if not the default 1000
# NOTE: USERNAME is a reserved variable in zsh and cannot be overridden by ARG value
ARG USER_NAME="vscode"
ARG USER_UID=1000
ARG USER_GID="${USER_UID}"
# apt-get "bootstrap" packages (and cleanup)
#
# sudo installed for sake of docker (see below)
# Verify git, process tools, installed
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils software-properties-common lsb-release dialog \
        sudo git less jq procps  rsync zsh zplug apt-transport-https \
        ca-certificates curl gnupg python3-pip groff man httpie 2>&1 \
    # cleanup
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# once installed use zsh, particularly for additional string substitution functionality
SHELL ["/usr/bin/zsh", "-c"]

# Setup apt providers starting with Docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null 

# setup google providers (for installing kubectl)
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" \
    | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

# setup helm provider
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - \
    && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Configure apt (again with new sources) and install packages from those sources
RUN apt-get update \
    && apt-get -y install docker-ce-cli kubectl helm \
    # cleanup (again)
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Additional docker setup
#
# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid ${USER_GID} ${USER_NAME} \
    && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USER_NAME} \
    # [Optional] Add sudo support for non-root user
    && echo ${USER_NAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER_NAME} \
    && chmod 0440 /etc/sudoers.d/${USER_NAME} \
    && groupadd docker && usermod -aG docker ${USER_NAME} && usermod -aG root ${USER_NAME}

# Install pylint and other pip packages
RUN pip --disable-pip-version-check --no-cache-dir install pylint ipykernel docker-compose

# install the AWS cli
ARG ZIP_OUT="/tmp/awscliv2.zip"
RUN PLAT=${$(uname -m)/arm64/aarch64}; \
    curl -L "https://awscli.amazonaws.com/awscli-exe-linux-${PLAT}.zip" -o "${ZIP_OUT}" \
    && unzip "${ZIP_OUT}" && ./aws/install && rm "${ZIP_OUT}" && rm -rf ./aws

# Terraform install (NOTE: no arm package for Terraform)
ARG TERRAFORM_VERSION=1.1.2
ARG TF_ZIP_OUT="/tmp/terraform.zip"
RUN PLAT=$(dpkg --print-architecture); \
    curl -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${PLAT}.zip -o "${TF_ZIP_OUT}" \
    && unzip "${TF_ZIP_OUT}" && mv terraform /usr/local/bin && rm "${TF_ZIP_OUT}"

# tfsec install
ARG TFSEC_VERSION="0.58.4"
ARG TMP_DIR="/tmp"

# # IMPORTANT: Two spaces are intentionally added before the tfsec path as it is the format produced
# # and expected by coreutils' checksum utilities.
# # See: https://www.gnu.org/software/coreutils/manual/coreutils.html#md5sum-invocation
RUN TFSEC_OUT="${TMP_DIR}/tfsec-${TFSEC_VERSION}-linux-${PLAT}"; \
    PLAT=$(dpkg --print-architecture); case "$PLAT" in \
        "arm64") TFSEC_SHA256SUM="3993705617e8ddb6bc3290a119aeef9c3e22813f992ff50e0690df9a690e97be" ;; \
        "amd64") TFSEC_SHA256SUM="f96fcf8fd22256192cd9ff7a6c8655c7012ff304c3a5eff332bd9d8ff43ed30b" ;; \
    esac \
    && curl -L "https://github.com/tfsec/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-${PLAT}" -o "${TFSEC_OUT}" \
    && echo "${TFSEC_SHA256SUM}  ${TFSEC_OUT}" > "${TMP_DIR}/tfsec_${TFSEC_VERSION}_SHA256SUM" \
    && sha256sum -c "${TMP_DIR}/tfsec_${TFSEC_VERSION}_SHA256SUM" \
    && mv "${TFSEC_OUT}" "/usr/local/bin/tfsec" && chmod +x /usr/local/bin/tfsec

# Install terraform-docs
ARG TERRAFORM_DOCS_VERSION="0.15.0"
RUN PLAT=$(dpkg --print-architecture); \
    wget -O - "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-$(uname)-${PLAT}.tar.gz" | tar -xzf - -C /usr/local/bin

# Install terragrant
ARG TERRAGRUNT_VERSION="0.35.3"
RUN PLAT=$(dpkg --print-architecture); \
    curl -L -o /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${PLAT}" && chmod +x /usr/local/bin/terragrunt

# Install latest tflint
ARG TFLINT_OUT="/tmp/tflint.zip"
RUN PLAT=$(dpkg --print-architecture); TFLINT_LATEST_VERSION=$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r .tag_name); \
    curl -sSL "https://github.com/terraform-linters/tflint/releases/download/${TFLINT_LATEST_VERSION}/tflint_linux_${PLAT}.zip" -o "${TFLINT_OUT}" \
    && unzip "${TFLINT_OUT}" && mv tflint /bin/tflint && rm "${TFLINT_OUT}"

# Install Bazel
# NOTE: There is not arm64 package for bazel, so we just download the appropriate release for the arch
# FIXME: This should possibly use bazelisk.  
ARG BAZEL_VERSION="4.0.0"
ARG BAZEL_BIN="/bin/bazel"
RUN PLAT=${$(uname -m)/aarch64/arm64}; \
    curl -L https://releases.bazel.build/${BAZEL_VERSION}/release/bazel-${BAZEL_VERSION}-linux-${PLAT} -o ${BAZEL_BIN} \
    && chmod +x ${BAZEL_BIN}

# install nix (based on this dockerfile: https://github.com/NixOS/docker/blob/master/Dockerfile)
ARG NIX_VERSION=2.3.15
ARG NIX_GID=30000
ARG NIX_USER=${USER_NAME}
ARG NIX_USER_UID=${USER_UID}
ARG NIX_USER_GID=${USER_GID}

RUN echo hosts: files dns > /etc/nsswitch.conf \
  && wget https://nixos.org/releases/nix/nix-${NIX_VERSION}/nix-${NIX_VERSION}-$(uname -m)-linux.tar.xz \
  && tar xf nix-${NIX_VERSION}-$(uname -m)-linux.tar.xz \
  && addgroup --system --gid ${NIX_GID} nixbld \
  && for i in $(seq 1 3); do adduser --system --disabled-password --home /var/empty --gecos "Nix build user $i" --uid $((30000 + i)) --gid ${NIX_GID} nixbld$i ; done \
  && mkdir -m 0755 /etc/nix \
  # run as privileged and set sandbox = true if you want to use nix sandboxing
  && echo 'sandbox = false' > /etc/nix/nix.conf \
  && echo "build-users-group =" >> /etc/nix/nix.conf \
  && install -d -m 0755 -o ${NIX_USER_UID} -g ${NIX_USER_GID} /nix 

# Setup nix to work for ${NIX_USER} user (FIXME: test installing nix as (single) vscode user, but unclear how this would later affect 
# sandboxing support).  See also: https://nixos.org/manual/nix/unstable/installation/single-user.html
USER ${NIX_USER}

ARG NIX_PROFILE_DIR="/nix/var/nix/profiles/per-user/${NIX_USER}/profile" 
RUN USER=${NIX_USER} sh nix-${NIX_VERSION}-$(uname -m)-linux/install \
# fixme: move this to the RUN command where the file is stored to save space in layers
  && sudo rm -rf /nix-${NIX_VERSION}-$(uname -m)-linux* \
  && ${NIX_PROFILE_DIR}/bin/nix-collect-garbage --delete-old \
  && ${NIX_PROFILE_DIR}/bin/nix-store --optimise \
  && ${NIX_PROFILE_DIR}/bin/nix-store --verify --check-contents

USER root

RUN ln -s ${NIX_PROFILE_DIR}/etc/profile.d/nix.sh /etc/profile.d/ 
  
# Nix related environment variables
ENV \
    ENV=/etc/profile \
    PATH=${PATH}:${NIX_PROFILE_DIR}/bin:${NIX_PROFILE_DIR}/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    NIX_PATH=/nix/var/nix/profiles/per-user/${NIX_USER}/channels

# Install buildifier tool for bazel
ARG BUILDIFIER_VERSION="4.2.4"
RUN PLAT=$(dpkg --print-architecture); \
    wget https://github.com/bazelbuild/buildtools/releases/download/${BUILDIFIER_VERSION}/buildifier-linux-${PLAT} -O /usr/local/bin/buildifier \
    && chmod +x /usr/local/bin/buildifier

# install opa 
# NOTE: not yet published for Linux ARM, but soon.  
# See this PR: https://github.com/open-policy-agent/opa/pull/4254
RUN PLAT=$(dpkg --print-architecture); \
    curl -L -o /usr/local/bin/opa https://github.com/open-policy-agent/opa/releases/download/v0.36.1/opa_linux_${PLAT} \
    && chmod 755 /usr/local/bin/opa

# install cosign locally (NOTE: important to have this version match the version that gets built with the bazel rules)
ARG COSIGN_VERSION="v1.8.0"
RUN PLAT=$(dpkg --print-architecture); \
    curl -L -o /usr/local/bin/cosign https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-${PLAT} \
    && chmod 755 /usr/local/bin/cosign

# install eksctl
RUN PLAT=$(dpkg --print-architecture); \
    wget -O - "https://github.com/weaveworks/eksctl/releases/download/v0.83.0-rc.0/eksctl_Linux_${PLAT}.tar.gz" \
    | tar -xzf - -C /usr/local/bin 

# install rekor CLI
ARG REKOR_VERSION=0.5.0
RUN PLAT=$(dpkg --print-architecture); \
    curl -L -o /usr/local/bin/rekor https://github.com/sigstore/rekor/releases/download/v${REKOR_VERSION}/rekor-cli-linux-${PLAT} \
    && chmod 755 /usr/local/bin/rekor

# install the spire-agent
RUN PLAT=$(dpkg --print-architecture); \
    wget -O - https://demo-binaries.s3.ap-southeast-2.amazonaws.com/spire-agent-1.2.0-linux-${PLAT}.tar.gz | tar -xzf - -C /usr/local/bin

# install cfssl
RUN PLAT=$(dpkg --print-architecture); \
    wget -O - https://demo-binaries.s3.ap-southeast-2.amazonaws.com/cfssl-1.6.1-linux-${PLAT}.tar.gz | tar -xzf - -C /usr/local/bin

ARG KUSTOMIZE_VERSION=4.5.4
RUN PLAT=$(dpkg --print-architecture); \
    wget -O - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${PLAT}.tar.gz \
    | tar -xzf - -C /usr/local/bin

USER vscode

# install cosign and crane for local use (NOTE: this will usually install latest of cosign
# to see available derivations try nix-env --query cosign --available)
RUN nix-env -iA nixpkgs.crane

RUN /usr/local/bin/python -m pip install -U pytest --user && \
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

COPY --chown=vscode workspace-setup/zshrc.template /home/vscode/.zshrc

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=



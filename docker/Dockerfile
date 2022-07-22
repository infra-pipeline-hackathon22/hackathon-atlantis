FROM golang:1.17-alpine AS builder

ARG ATLANTIS_VERSION="0.19.6"
RUN wget https://github.com/runatlantis/atlantis/archive/refs/tags/v${ATLANTIS_VERSION}.tar.gz -O - | tar -xz && mv atlantis-${ATLANTIS_VERSION} /app

WORKDIR /app
# do go install before patching to maybe limit rebuild time
RUN CGO_ENABLED=0 go install

# patch go source code with multienv fix
COPY patch/go/multienv_step_runner.go /app/server/core/runtime/multienv_step_runner.go
RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -v -o atlantis .

FROM ghcr.io/runatlantis/atlantis:v0.19.6 as base

LABEL org.opencontainers.image.source="https://github.com/infra-pipeline-hackathon22/hackathon-atlantis"

# copy binary
COPY --from=builder /app/atlantis /usr/local/bin/atlantis

USER root

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
ADD requirements.txt /tmp
RUN pip3 install --no-cache --upgrade pip setuptools && pip3 install -r /tmp/requirements.txt
ADD --chown=atlantis --chmod=755 python /python

USER atlantis

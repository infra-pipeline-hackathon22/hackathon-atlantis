FROM ghcr.io/runatlantis/atlantis:v0.19.6

LABEL org.opencontainers.image.source="https://github.com/infra-pipeline-hackathon22/hackathon-atlantis"

USER root

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
ADD requirements.txt /tmp
RUN pip3 install --no-cache --upgrade pip setuptools && pip3 install -r /tmp/requirements.txt
WORKDIR /app
COPY identity.py roles.json .


USER atlantis
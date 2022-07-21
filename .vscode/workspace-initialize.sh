#!/bin/bash

set -euo pipefail

# create local mountpoints for bazel if they don't exist already
if [ ! -d .devcontainer/mount/bazel-cache ]; then
    mkdir -p .devcontainer/mount/bazel-cache
fi

# TODO having a local nix store is more problematic as 
if [ ! -d .devcontainer/mount/nix-store ]; then
    mkdir -p .devcontainer/mount/nix-store
fi
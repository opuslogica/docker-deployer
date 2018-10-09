#! /bin/bash

set -e

deployment_url="$1"
commit_hash="$2"

if [[ -z "$deployment_url" ]]; then
    echo "./kill-dev.sh <deployment_url> <commit_hash>"
    local commit_hash=$(git rev-parse HEAD | cut -c1-7)
    echo "If you want to kill the current commit hash it is: $commit_hash"
fi

set -u

ssh deployer@"$deployment_url" "cd ./docker-deployer && ./kill-remote.sh $commit_hash"

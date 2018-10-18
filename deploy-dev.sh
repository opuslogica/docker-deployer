#! /bin/bash

set -e

deployment_url="$1"
commit_hash="$2"

if [[ -z "$deployment_url" ]]; then
    echo "./deploy-dev.sh <deployment_url> <commit_hash>"
    echo "(The <deployment_url> you want is probably \"docker.jobspeaker.com\")"
    commit_hash=$(git rev-parse HEAD | cut -c1-7)
    echo "If you want to deploy with the current commit hash it is: $commit_hash"
    exit 1
fi

set -u

# assumes there is a deployer user with the docker-deployer repo cloned into the
# home directory as specified in the README
ssh deployer@"$deployment_url" "cd ./docker-deployer && ./remote.sh $commit_hash"

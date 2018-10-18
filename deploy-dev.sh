#! /bin/bash

set -e

deployment_url="$1"
branch="$2"
commit_hash="$3"

if [[ -z "$deployment_url" || -z "$commit_hash" || -z "$branch" ]]; then
    echo "./deploy-dev.sh <deployment_url> <branch> <commit_hash>"
    commit_hash=$(git rev-parse HEAD | cut -c1-7)
    echo "If you want to deploy with the current commit hash it is: $commit_hash"
    exit 1
fi

set -u

# assumes there is a deployer user with the docker-deployer repo cloned into the
# home directory as specified in the README
ssh deployer@"$deployment_url" "cd ./docker-deployer && ./remote.sh $branch $commit_hash"

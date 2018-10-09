#! /bin/bash

set -e

git_hash="$1"

if [[ -z "$git_hash" ]]; then
    echo "./remote.sh <git hash>"
    exit 1
fi

source ./variables.sh

set -u

function main
{
    trap "return_error 'Failed to bring down container'" EXIT

    local compose_directory="./tmp/$git_hash"
    # This is only used at build time but it needs to be set to something
    # in order for the docker-compose commands to run
    local api_port="foo"
    pushd "$compose_directory"
    docker-compose down
    popd
    rm -rf "$compose_directory"

    trap - EXIT
}

function return_error
{
    error_message="$1"
    echo "$error_message"
    exit 1
}

main

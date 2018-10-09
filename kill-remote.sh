#! /bin/bash

set -e

export git_hash="$1"

if [[ -z "$git_hash" ]]; then
    echo "./kill-remote.sh <git hash>"
    exit 1
fi

source ./variables.sh

set -u

function main
{
    trap "return_error 'Failed to bring down container'" EXIT

    local compose_directory="./tmp/$git_hash"
    # This is only used at build time but it needs to be set to a number
    # in order for the docker-compose commands to run
    export api_port="3000"
    pushd "$compose_directory"

    # Bring down the containers
    docker-compose down
    popd

    # Remove the temporary directory so that the
    # container may be relaunched if needed
    rm -rf "$compose_directory"

    # Remove the apache configuration so that it doesn't
    # conflict with other configurations in the future
    rm "/etc/apache2/sites-enabled/$git_hash.conf"

    # Restart apache
    sudo apachectl restart

    trap - EXIT
}

function return_error
{
    error_message="$1"
    echo "$error_message"
    exit 1
}

main

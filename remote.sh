#! /bin/bash

set -e

# We export the git_hash so it may be used within the compose file
export branch="$1"
export git_hash="$2"

if [[ -z "$branch" || -z "$git_hash" ]]; then
    echo "./remote.sh <branch> <git hash>"
    exit 1
fi

# ./variables.sh should have the needed configuration as specified in
# the README
source ./variables.sh

set -u

function main
{
    local available_port="$(find_port)"
    run_container "$available_port"
    update_apache "$available_port"
    wait_for_container "$available_port"
}

# TODO this function is supposed to do some cleanup and possibly some
# extra notification stuff
function return_error
{
    error_message=$1
    echo "$error_message"
    exit 1
}


function find_port
{
    trap "return_error 'Failed to find open port'" EXIT

    local IP=localhost
    local first_port=1025
    local last_port=65535
    local available_port
    for ((port=$first_port; port<=$last_port; port++))
    do
        (echo >/dev/tcp/$IP/$port)> /dev/null 2>&1 || available_port="$port"
        set +u
	if [[ ! -z $available_port ]]; then
	    break
	fi
        set -u
    done
    echo "$available_port"
    trap - EXIT
}

function run_container
{
    trap "return_error 'Failed to run container'" EXIT

    local container_internal_port=3000
    local compose_dir="./tmp/${git_hash}"

    # Exported for the compose file
    export api_port="$1"

    # Create a special directory just for this git hash
    mkdir -p "$compose_dir"
    # These are the files that are necessary for the build and run to complete
    # They cannot be soft linked because they must actually be in the directory
    # TODO maybe hard link
    cp cmd.sh db_dump git.key Dockerfile docker-compose.yml "$compose_dir"

    # Run it
    pushd "$compose_dir"
    docker-compose build
    docker-compose up -d
    popd

    trap - EXIT
}

function update_apache
{
    trap "return_error 'Failed to update apache'" EXIT

    local available_port="$1"
    local full_name="${git_hash}.${deployment_url}"

    sudo apachectl stop

    # Check if a cert already exists or not
    if [[ ! -d "/etc/letsencrypt/live/${full_name}" ]]; then
	sudo certbot certonly --email "$email" \
             --standalone \
             --domain "${full_name}" \
             --agree-tos \
             -n # run non-interactively
    fi

    # Generate the apache configuration
    sed -e "s/\${available_port}/${available_port}/g" \
	-e "s/\${server_name}/${full_name}/g" \
	site.conf.tmpl > /etc/apache2/sites-enabled/"$git_hash".conf

    sudo apachectl start

    trap - EXIT
}

function wait_for_container
{
    trap "return_error 'Container failed to launch'" EXIT

    local port="$1"

    echo "Waiting for container..."
    set +e
    while [[ true ]]; do
        if curl localhost:"$port" &> /dev/null ; then
            break
        else
            echo "still waiting for container ... "
            sleep 5
        fi
    done
    set -e
    echo "Container successfully launched!"
    echo "Your container is now available on <'http' | 'https'>://${git_hash}.${deployment_url}"

    trap - EXIT
}

main

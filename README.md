# docker-deployer
This is a project to deploy multiple instances of a rails based application.
The deployments are done via docker on the remote host and the application version is determined via git hash.

## Requirements
* `./git.key` is the ssh private key which will let you clone.
  * It is included in .gitignore, so it will not be committed
* (Docker)[https://docs.docker.com/install/]
* (Apache)[https://www.apache.org]
* (letsencrypt (certbot))[https://certbot.eff.org]
* (docker-compose)[https://docs.docker.com/compose/install/]
* The following apache modules
  * `a2enmod <ssl & proxy & proxy_http>`
* Building the containers
  * Get the necessary variables into the current shell by running `source ./variables.sh` (See Variables to set for how to make this file)
  * There are run-time arguments which are required to be set in order to build the api container. `api_port` and `git_hash` should be set to some non-empty string to satisfy docker-compose.
	* `docker-compose build`

## Architecture
* The developer deploys a container which runs the api versioned to a specific commit identified by the first 7 characters of the git hash.
* That container is then reachable via `<"http" | "https">://<git_hash>.<deployment_url>` (see Variables to set for `deployment_url` description)
  * The host apache reverse proxies to the container forwarded port stripping ssl in
    the process and adding it back in for the response.
* This deployment is accomplished by running `./deploy-dev.sh <deployment_url>` in the root directory of the api to deploy the most recent commit on the current branch.
  * This script assumes there is a deployer user for whom the local user has ssh access and that this repo has been cloned into that user's home directory
* `remote.sh <git hash>` is run on the remote host which will run a container with the api as the specified version on the next available port.
  It will then add an apache configuration which will take care of the previously described reverse proxy process as well as obtain an ssl certificate for the new sub domain.
  * Obviously apache is also restarted
* docker-compose is used each time with the given git hash. The different runs are distinguished
  by making a new directory named the git hash under ./tmp and copying the compose file into said
  directory

## Variables to set
* There are a few variables that are required to be set.
* Variables are set by copying `variables.sh.tmpl` to `variables.sh` (ignored by git). The variables are set to blank strings. Fill them in as described below.
* `deployment_url` is the url that all the api servers will be reachable via. For a deployment with a given git hash, the deployed server will be reachable via `<git_hash>.<deployment_url>`.
* `repo_name` is the name of the git repository that will be used. Note: this is not the full url (or the propper name for the ssh equivalent).
* `git_server` is the url the git server is reachable at. This results in the full url being `<git_server>/<repo_name>` Note: we assume you're using ssh access.
* `ruby_version` is the version of ruby that will be installed via rvm
* `mysql_root_password` is the password for the root user on the mysql container
* `db_name` is the name of the database that will be loaded from `./db_dump`
* `mysql_user` is the user who will access the database from the rails application
* `mysql_password` is the password that `mysql_user` will use to access the container

`./db_dump` is the dump of the database (this is ignored by git).
`./site.conf.tmpl` is the template for the generated apache config.
`./cmd.sh` is the CMD for the api container

In order to save on container startup times, the repo and gems are all setup at build time. When the container is run, then the repo is reset to the new git hash and `bundle install` is re-run

We assume that the rails application will be run on port 3000 inside the container

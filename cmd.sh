#! /bin/bash

set -e

if [[ -z "$git_hash" || -z "$deployment_url" || -z "$repo_name" || -z "$mysql_root_password" || -z "$db_name" ]]; then
    echo "git_hash, deployment_url, and repo_name are all required"
    exit 1
fi

source /etc/profile.d/rvm.sh

wait-for-it.sh db:3306 -t 0
mysql -hdb -uroot -p"$mysql_root_password" "$db_name" < /db_dump

# The repo should have already bin cloned, so we just reset to the given hash and
# install any non-installed gems
cd "$repo_name"
git reset --hard "$git_hash"
bundle install

export backend_url="https://${git_hash}.${deployment_url}"

RAILS_ENV=production ./bin/rake assets:precompile
RAILS_ENV=production RAILS_SERVE_STATIC_FILES=yes ./bin/rails s -b 0.0.0.0

#! /bin/bash

set -e

all_set=1
[[ -z "$git_hash" ]] || all_set=0
[[ -z "$deployment_url" ]] || all_set=0
[[ -z "$repo_name" ]] || all_set=0
[[ -z "$mysql_root_password" ]] || all_set=0
[[ -z "$db_name" ]] || all_set=0
[[ -z "$branch" ]] || all_set=0

if [[ ! "$all_set" = 0 ]]; then
    echo "git_hash, deployment_url, repo_name, and branch are all required"
    exit 1
fi

source /etc/profile.d/rvm.sh

wait-for-it.sh db:3306 -t 0
mysql -hdb -uroot -p"$mysql_root_password" "$db_name" < /db_dump

# The repo should have already been cloned,
# so we just check out the given branch,
# reset to the given hash, and
# install any non-installed gems
cd "$repo_name"
git pull origin "$branch"
git checkout "$branch"
git reset --hard "$git_hash"
bundle install

export backend_url="https://${git_hash}.${deployment_url}"

RAILS_ENV=development ./bin/rake assets:precompile
RAILS_ENV=development RAILS_SERVE_STATIC_FILES=yes ./bin/rails s -b 0.0.0.0

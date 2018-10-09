FROM ubuntu:16.04

MAINTAINER William Berman

# Obligitory apt-get update, installation of required packages, and link node binary
RUN apt-get update
RUN apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	nodejs \
	libcurl4-openssl-dev \
	apache2-dev \
	libapr1-dev \
	libaprutil1-dev \
	gnupg \
	build-essential \
	dirmngr \
	libapache2-mod-passenger \
	apache2 \
	emacs \
	vim \
	git \
	libmysqlclient-dev \
	imagemagick \
	libmagickwand-dev

# For some reason we have to do this apt-get update and separate installation
# of tzdata before continuing with the rest of the packages. Don't ask me why
# and just let it be ¯\_(ツ)_/¯
RUN apt-get update
RUN apt-get install -y tzdata

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get install -y \
	mysql-server \
	mysql-client \
	postgresql \
	postgresql-contrib \
	libpq-dev

RUN ln -sf /usr/bin/nodejs /usr/local/bin/node

# Install rvm and the required ruby version specified by ruby_version
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN usermod -a -G rvm `whoami`
ARG ruby_version
RUN /bin/bash -c "source /etc/profile.d/rvm.sh && rvm install ruby-${ruby_version} && rvm --default use ruby-${ruby_version} && gem install bundler --no-rdoc --no-ri"

# Install wait-for-it
RUN git clone https://github.com/vishnubob/wait-for-it /tmp/wait-for-it \
    && mv /tmp/wait-for-it/wait-for-it.sh /usr/local/bin/wait-for-it.sh

# Setup the .ssh directory so we can clone the repo
RUN mkdir -p /root/.ssh
COPY ./git.key /root/.ssh/id_rsa

# Copy in the db dump, and clone the api repo
COPY ./db_dump  /

# Allow automatic ssh and clone the repo
# Set the needed db config file
ARG git_server
ARG repo_name
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts \
	&& git clone "${git_server}"/"${repo_name}" \
	&& cd "${repo_name}" \
	&& cp ./config/database.yml-docker ./config/database.yml \
	&& cp ./config/application.yml-docker ./config/application.yml

# Install current gems (bundle install will be re-run at runtime)
# The same will be done for precompiling the assets
RUN /bin/bash -c "source /etc/profile.d/rvm.sh \
	&& cd "${repo_name}" \
	&& bundle install \
	&& RAILS_ENV=production ./bin/rake assets:precompile"

COPY cmd.sh /usr/bin/cmd.sh
CMD ["cmd.sh"]

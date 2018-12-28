# docker-deployer
This is a basic single host docker deployment solution.

## Requirements
* [Docker](https://docs.docker.com/install/)
* [Apache](https://www.apache.org)
* [letsencrypt (certbot)](https://certbot.eff.org)
* [docker-compose](https://docs.docker.com/compose/install/)
* The following apache modules
  * `a2enmod <ssl & proxy & proxy_http>`
* The deployer user should have passwordless sudo for `apachectl` and `certbot`.
  * `sudo visudo` and then insert
    ```
    deployer ALL = (root) NOPASSWD: /usr/sbin/apachectl
    deployer ALL = (root) NOPASSWD: /usr/bin/certbot
    ```
* The deployer user should have permission to edit `/etc/apache2`
  * `sudo setfacl -R -m u:deployer:rwx /etc/apache2/`
* certbot is used for obtaining ssl certificates, and it requires an email
  * `echo <email> > certbot_email.txt` 

## Architecture
* Users may deploy application instances via specifying a git url, a docker-compose file, a git branch, and a commit hash.
* The deployed application may then be reached at `<"http" | "https">://.< first 7 characters of commit hash >.< branch >.< project name >.deployment.< regular website domain >`
  * The host apache reverse proxies to the container forwarded port stripping ssl in
    the process and adding it back in for the response.
* These deployments may then be 'pinned' such that other users may repeat them.
* Users are authorized via a username password combo which returns a token.
* All necessary state is stored in `./db.json` (ignored via git)
* A light-weight server is run at port 8080

## Command line access
* Upon first access, user's are required to authenticate via their username and password. The resulting token is stored at `~/.docker-deployer/token`
* See `./<script name> --help` for usage

## Website access
* A web interface is provided at `web.< regular website domain >`

`./site.conf.tmpl` is the template for the generated apache config.

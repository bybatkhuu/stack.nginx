# NGINX Stack

This is a docker-compose stack for NGINX with Certbot (Let's Encrypt).

## Features

- NGINX - <https://nginx.org>
- Let's Encrypt - <https://letsencrypt.org>
- Certbot - <https://certbot.eff.org>
- TLS/SSL certificates
- Automatic certificate obtain
- Automatic certificate renewal (checks every week)
- DNS challenges **[recommended]**:
    - Cloudflare DNS
    - DigitalOcean DNS
    - GoDaddy DNS
    - AWS Route53
    - Google Cloud DNS
- HTTP challenges:
    - Standalone
    - Webroot
- Multiple domains per certificate
- Subdomains:
    - Multiple subdomains per domain/certificate
    - Wildcard subdomains (only DNS challenges)
- NGINX template configuration
- Web server
- Reverse proxy
- Load balancer
- Rate limiting
- HTTP cache
- HTTP header transformations
- HTTP/2 and HTTPS
- Basic authentication
- Websockets
- Docker and docker-compose

---

## Getting started

### 1. Prerequisites

- **Server** with **public IP address**
- Buy or register **domain name**
- **[RECOMMENDED]** DNS provider **API token/credentials** (required for **DNS challenges** and **wildcard subdomains**):
    - Cloudflare - <https://dash.cloudflare.com/profile/api-tokens>
    - DigitalOcean - <https://cloud.digitalocean.com/account/api/tokens>
    - GoDaddy - <https://developer.godaddy.com/keys>
    - AWS Route53 - <https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys>
    - Google Cloud DNS - <https://cloud.google.com/docs/authentication/getting-started>
- Install **docker** and **docker-compose** in **server** - <https://docs.docker.com/engine/install>

For **development**:

- Install **git** - <https://git-scm.com/downloads>
- Setup an **SSH key** - <https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh>

### 2. Download or clone the repository

**2.1.** Prepare projects directory (if not exists) in your **server** with **public IP address**:

```sh
# Create projects directory:
mkdir -pv ~/workspaces/projects

# Enter into projects directory:
cd ~/workspaces/projects

# Set repository owner:
export _REPO_OWNER=[REPO_OWNER]
# For example:
export _REPO_OWNER=username
```

**2.2.** Follow one of the below options **[A]**, **[B]** or **[C]**:

**A.** Download source code from releases page:

- Releases - <https://github.com/[REPO_OWNER]/stack.nginx/releases>

```sh
# Set to downloaded version:
export _VERSION=[VERSION]
# For example:
export _VERSION=1.0.0

# Move downloaded archive file to current projects directory:
mv -v ~/Downloads/stack.nginx-${_VERSION}.zip .

# Extract downloaded archive file:
unzip stack.nginx-${_VERSION}.zip

# Remove downloaded archive file:
rm -v stack.nginx-${_VERSION}.zip

# Rename extracted directory into project name:
mv -v stack.nginx-${_VERSION} stack.nginx && cd stack.nginx
```

**B.** Or clone the repository (git + ssh key):

```sh
git clone git@github.com:${_REPO_OWNER}/stack.nginx.git && cd stack.nginx
```

**C.** **[For development]** Or clone with all submodules (git + ssh key):

```sh
git clone --recursive git@github.com:${_REPO_OWNER}/stack.nginx.git && cd stack.nginx && \
    git submodule update --init --recursive && git submodule foreach --recursive git checkout main
```

### 3. Configure environment

**TIP:** Skip this step, if you've already configured environment.

**3.1.** Configure **`.env`** file:

**IMPORTANT:** Please, check **[environment variables](#environment-variables)**!

```sh
# Copy .env.example file into .env file:
cp -v .env.example .env

# Edit environment variables to fit in your environment:
nano .env
```

**3.2.** Configure **`docker-compose.override.yml`** file:

**IMPORTANT:** Please, check **[arguments](#arguments)**!

```sh
# Set environment:
export _ENV=[ENV]
# For example for development environment:
export _ENV=dev

# Copy docker-compose.override.[ENV].yml into docker-compose.override.yml file:
cp -v ./templates/docker-compose/docker-compose.override.${_ENV}.yml docker-compose.override.yml

# Edit docker-compose.override.yml file to fit in your environment:
nano docker-compose.override.yml
```

**3.3.** Validate docker compose configuration:

**NOTICE:** If you get an error or warning, check your configuration files (**`.env`** or **`docker-compose.override.yml`**).

```sh
./certbot-compose.sh validate

# Or:
docker compose config
```

### 4. Configure NGINX

**TIP:** Skip this step, if you've already configured NGINX.

**IMPORTANT:** Please, check nginx configuration and best practices:

- <https://www.udemy.com/course/nginx-fundamentals>
- <https://www.baeldung.com/linux/nginx-config-environment-variables>
- <https://www.youtube.com/watch?v=pkHQCPXaimU>
- <https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes>
- <https://www.nginx.com/nginx-wiki/build/dirhtml/start/topics/tutorials/config_pitfalls>
- <https://www.digitalocean.com/community/tools/nginx>
- <https://github.com/fcambus/nginx-resources>

```sh
# Choose template file to use:
export _TEMPLATE_BASENAME=[_TEMPLATE_BASENAME]
# For example:
export _TEMPLATE_BASENAME=example.com.https.lets

# Set custom template file name:
export _CUSTOM_BASENAME=[_CUSTOM_BASENAME]
# For example:
export _CUSTOM_BASENAME=example.com

# Copy template file into storage directory:
cp -v ./templates/nginx.conf/${_TEMPLATE_BASENAME}.conf.template ./volumes/storage/nginx/configs/templates/${_CUSTOM_BASENAME}.conf.template

# Edit template file to fit in your nginx configuration:
nano ./volumes/storage/nginx/configs/templates/${_CUSTOM_BASENAME}.conf.template
```

### 5. Run docker compose

```sh
./certbot-compose.sh start -l

# Or:
docker compose up -d && docker compose logs -f --tail 100
```

### 6. Check certificates

```sh
./certbot-compose.sh certs

# Or check certificates in container:
docker compose exec certbot certbot certificates

# Or check certificates in host:
ls -alhF ./volumes/storage/nginx/ssl

# Or check certificates in host with tree:
tree -alFC --dirsfirst -L 5 ./volumes/storage/nginx/ssl
```

### 7. Stop docker compose

```sh
./certbot-compose.sh stop

# Or:
docker compose down
```

:thumbsup: :sparkles:

---

## Environment Variables

You can use the following environment variables to configure:

[**`.env.example`**](.env.example)

```sh
# Docker image namespace:
IMG_NAMESCAPE=username

## Certbot:
CERTBOT_EMAIL=user@email.com
CERTBOT_DOMAINS="example.com,www.example.com"
CERTBOT_DNS_TIMEOUT=30

## NGINX:
# NGINX_BASIC_AUTH_USER=nginx_admin
# NGINX_BASIC_AUTH_PASS="admin_password"
# NGINX_HTTP_PORT=80
# NGINX_HTTPS_PORT=443
```

## Arguments

You can use the following arguments to configure:

**nginx**:

```txt
-s=*, --https=[self | valid | lets]
    Enable HTTPS mode:
        self  - Self-signed certificate
        valid - Valid certificate
        lets  - Let's Encrypt certificate
-b, --bash, bash, /bin/bash
    Run only bash shell.
```

For example as in [**`docker-compose.override.yml`**](templates/docker-compose/docker-compose.override.dev.yml) file:

```yml
    command: ["--https=self"]
    command: ["--https=valid"]
    command: ["--https=lets"]
    command: ["/bin/bash"]
```

**certbot**:

```txt
-s=, --server=[staging | production]
    Let's Encrypt server. Default: staging.
-n=, --new=[standalone | webroot]
    Obtain option for new certificates. Default: standalone.
-r=, --renew=[webroot | standalone]
    Renew option for existing certificates. Default: webroot.
-d=, --dns=[cloudflare | route53 | google | godaddy | digitalocean]
    Use DNS challenge instead of HTTP challenge.
-D, --disable-renew
    Disable automatic renewal of certificates.
-b, --bash, bash, /bin/bash
    Run only bash shell.
```

For example as in [**`docker-compose.override.yml`**](templates/docker-compose/docker-compose.override.dev.yml) file:

```yml
    command: ["--server=production"]
    command: ["--server=production", "--renew=standalone"]
    command: ["--new=webroot", "--disable-renew"]
    command: ["--server=production", "--dns=cloudflare"]
    command: ["--dns=digitalocean"]
    command: ["--dns=route53"]
    command: ["--dns=google"]
    command: ["--dns=godaddy"]
    command: ["/bin/bash"]
```

## Roadmap

- Add GitHub action for auto-update CHANGELOG.md file.
- Add more DNS providers.
- Add more documentation.

---

## References

- Download NGINX - <https://nginx.org/en/download.html>
- Building NGINX from sources - <https://nginx.org/en/docs/configure.html>
- NGINX documentation - <https://nginx.org/en/docs>
- NGINX directives - <https://nginx.org/en/docs/dirindex.html>
- NGINX variables - <https://nginx.org/en/docs/varindex.html>
- NGINX config generator (digitalocean) - <https://www.digitalocean.com/community/tools/nginx>
- NGINX 3rd party modules - <https://www.nginx.com/resources/wiki/modules>
- NGINX Avoid top 10 mistakes - <https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes>
- NGINX Pitfalls and common mistakes - <https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls>
- Installing NGINX open source and NGINX Plus - <https://www.youtube.com/watch?v=pkHQCPXaimU>
- NGINX Proxy Manager - <https://nginxproxymanager.com>
- NGINX fundamental course - <https://www.udemy.com/course/nginx-fundamentals>
- NGINX resources - <https://github.com/fcambus/nginx-resources>
- NGINX config environment variables - <https://www.baeldung.com/linux/nginx-config-environment-variables>
- Certbot - <https://certbot.eff.org>
- Certbot documentation - <https://eff-certbot.readthedocs.io/en/stable>
- Let's Encrypt - <https://letsencrypt.org>
- Let's Encrypt documentation - <https://letsencrypt.org/docs>

<h1 align="center">
    Mrbs-docker
</h1>

<p align="center">
    <a href="https://github.com/dorianim/mrbs-docker/releases/latest">
        <img src="https://img.shields.io/github/v/release/dorianim/mrbs-docker?logo=github&logoColor=white" alt="GitHub release"/>
    </a>
    <a href="https://www.gnu.org/licenses/agpl-3.0">
        <img src="https://img.shields.io/badge/License-AGPL%20v3-blue.svg" />
    </a>
    <a href="https://github.com/dorianim/mrbs-docker/actions/workflows/release.yml">
        <img src="https://github.com/dorianim/mrbs-docker/actions/workflows/release.yml/badge.svg" alt="Badge release image" />
    </a>
    <a href="https://hub.docker.com/r/dorianim/mrbs">
        <img src="https://img.shields.io/docker/pulls/dorianim/mrbs.svg" alt="Docker pulls" />
    </a>
</p>

This is a docker container for the [Meeting room booking system](https://github.com/meeting-room-booking-system/mrbs-code).

## Features

- Automatic installation
- Easy updating
- Includes [SimpleSAMLphp](SimpleSAMLphp) to allow SAML authentication
- [Modern MRBS theme](https://github.com/dorianim/modern-mrbs-theme) included

# Installation

1. Create a folder for installation:
   ```bash
   mkdir /opt/mrbs-docker && cd /opt/mrbs-docker
   ```
2. Create the file docker-compose.yml with this content:
   ```yaml
   version: "2"
   services:
     mrbs:
       image: dorianim/mrbs
       container_name: mrbs
       environment:
         - PUID=1000
         - PGID=1000
         - TZ=Europe/Berlin
         - DB_HOST=mrbs-db
         - DB_USER=mrbs-user
         - DB_PASS=mrbs-pass
         - DB_DATABASE=mrbs
         # can be mysql or pgsql
         - DB_TYPE=mysql
       volumes:
         - ./config/mrbs:/config
       ports:
         - 8888:80
       restart: unless-stopped
       depends_on:
         - mrbs-db
     mrbs-db:
       image: mariadb:latest
       container_name: mrbs-db
       environment:
         - PUID=1000
         - PGID=1000
         - MYSQL_ROOT_PASSWORD=mrbs-root-pass
         - TZ=Europe/London
         - MYSQL_DATABASE=mrbs
         - MYSQL_USER=mrbs-user
         - MYSQL_PASSWORD=mrbs-pass
       volumes:
         - ./config/mysql:/var/lib/mysql
       restart: unless-stopped
   ```
   PLEASE NOTE: If you're trying to run this on a raspberry pi, please use `jsurf/rpi-mariadb` for the database instead of `mariadb`.
3. Adjust the port (default `8888`) to your needs
4. Start the mrbs-docker:
   ```bash
   docker-compose up -d
   ```
5. Done! You can reach your mrbs-docker on `localhost:5080`
6. Adjust your `config.inc.php` in `/opt/mrbs-docker/config/mrbs/www/config.inc.php`

# Updating

To update, just go to your installation folder and pull

```bash
cd /opt/mrbs-docker
docker-compose pull
docker-compose down && docker-compose up -d
```

# SAML Authentication

To configure SAML Authentication, you need to add these lines to your config.inc.php:

```php
$auth['type'] = 'saml';
$auth['session'] = 'saml';
$auth['saml']['ssp_host'] = '<host of your mrbs, eg https://mrbs.company.com/, with a trailing slash>';
$auth['saml']['ssp_idp'] = '<issuer of your SAML idp>';
$auth['saml']['ssp_entity_id'] = '<client id of your SAML idp>';
$auth['saml']['ssp_single_sign_on_service'] = '<single sign on endpoint of your SAML idp>';
$auth['saml']['ssp_single_logout_service'] = '<single logout endpoint of your SAML idp>';
$auth['saml']['ssp_cert_data'] = '<base64 encoded certificate data of your SAML idp>';

$auth['saml']['attr']['username'] = '<username attribute>';
$auth['saml']['attr']['mail'] = '<email attribute>';
$auth['saml']['attr']['givenName'] = '<givenName attribute>';
$auth['saml']['attr']['surname'] = '<surname attribute>';
$auth['saml']['admin']['<group list attribute>'] = ['<admin group>'];
```

If you want to use SAML authentication with mrbs behind a SSL reverse proxy you need to set
```php
$auth['saml']['ssp_secure_cookie'] = true;
```

- You can test the authentication here: `mrbs.company.com/simplesaml/module.php/core/authenticate.php`. It will also show you all transmitted attributes.
- The admin password for simplesaml can be found in `config/keys/secretsalt`.
- You need to add the redirect URL `https://mrbs.company.com/simplesaml/module.php/saml/sp/saml2-acs.php/default-sp`
- You need to add the Logout Service POST Binding URL `https://mrbs.company.com/simplesaml/module.php/saml/sp/saml2-logout.php/default-sp`

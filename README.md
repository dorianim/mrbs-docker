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
        image: dorianim/mrbs-docker
        container_name: mrbs
        environment:
        - PUID=1000
        - PGID=1000
        - DB_HOST=mrbs-db
        - DB_USER=mrbs-user
        - DB_PASS=mrbs-pass
        - DB_DATABASE=mrbs
        volumes:
        - ./config/mrbs:/config
        ports:
        - 8888:80
        restart: unless-stopped
        depends_on:
        - mrbs-db
    mrbs-db:
        image: mariadb:latest
        container_name: mrbs_db
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
1. Adjust the port (default `8888`) to your needs
2. Start the mrbs-docker:
    ```bash
    docker-compose up -d
    ```
3. Done! You can reach your mrbs-docker on `localhost:5080`
4. Adjust your `config.inc.php` in `/opt/mrbs-docker/config/www/config.inc.php`

# Updating
To update, just go to your installation folder and pull  
```bash
cd /opt/mrbs-docker
docker-compose pull
docker-compose down && docker-compose up -d
```

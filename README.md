# Wildfly MySQL DevStack

[![Docker Automated build](https://img.shields.io/docker/automated/kaaass/wildfly-mysql.svg)](https://hub.docker.com/r/kaaass/wildfly-mysql/)

## About

This repo contains the DevStack Dockerfile.  
Your feedback is always welcome.

### Features

The development stack consists of:

- [x] **Wildfly**: Java EE application server
	- [x] Preconfigured [JNDI datasource]()
	- [x] Administration Console
- [x] **MySQL**: Relational database management system

### Requirements

- [Docker](https://docs.docker.com/engine/installation/) (including docker-compose)

## Quick Start

This section gives you a quick overview on how to get started.

### Using docker-compose (Recommend)

Clone the repository and checkout the branch if you need.

```sh
$ git clone https://github.com/kaaass/wildfly-mysql.git
$ cd wildfly-mysql
# (optional but recommend) checkout a specific branch
$ git checkout java-11-wildfly-23.0.0.Final-mysql-8.0
```

Boot the environment by running:

```sh
# starts the `app` and `db` containers
$ docker-compose up -d
```

Now you can access the components:

- **Wildfly**
	- Application: http://localhost:8080
	- Administration Console: http://localhost:9990
	- Jvm Remote Debug: `localhost:8787`, disabled in default
	- JNDI name: `/jdbc/datasources/sampleDS`
- **MySQL**
	- Connection: `localhost:13306`

Stop the environment:

```sh
# remove the containers
$ docker-compose down
```

### Using Image from Docker Hub

```sh
$ docker pull kaaass/wildfly-mysql:latest
```

Available Tags:

- latest
- java-11-wildfly-23.0.0.Final-mysql-8.0
- java-8-wildfly-13.0.0.Final-mysql-5.7
- java-7-jboss-as-7.1.1.Final-mysql-5.7

## Configuration

> The following environment variables show the default values.

For docker-compose way, edit `.env` to change the environment variables.

#### App Server

[Official WildFly image documentation](https://store.docker.com/community/images/jboss/wildfly)

Environment variables:

- WILDFLY_DEBUG=false|true
- WILDFLY_USER=admin
- WILDFLY_PASS=adminPassword
- Database configuration  
	*This config must match the one of the MySQL database (name, user, password).*
	- DB_NAME=sample  
		**Important:** The JNDI name follows the pattern: `/jdbc/datasources/<DB_NAME>DS`
	- DB_USER=mysql
	- DB_PASS=mysql

Arguments:

- WILDFLY_VER=23.0.0.Final
- MYSQL_CONNECTOR_VERSION=8.0.23

#### Database

[Official MySQL image documentation](https://store.docker.com/images/mysql)

- MYSQL_DATABASE=sample
- MYSQL_USER=mysql
- MYSQL_PASSWORD=mysql
- MYSQL_ROOT_PASSWORD=supersecret
	- **Hint:** This is the password for the MySQL `root` user.

## Develop with IntelliJ IDEA

Debugging your project with this repository in IntelliJ IDEA is quite simple. It is recommend to add Run/Debug Configuration to achieve this.

1. Open `Run/Debug Configurations`. Click `Add New Configuration` - `Docker` - `Docker-compose`. You might need to install `Docker` plugin to get these options in old IDEAs.
2. In `Compose file(s)`, select `docker-compose.yml`.
3. In `Service(s)`, type `app`.
4. Add following `Environment variables`:
   1. `DEPLOYMENT_PATH`: path your `.war` file located. For Gradle project, use `{path to your project}/build/libs/`
   2. (optional, recommend) `WILDFLY_DEBUG`: set `true` to enable remote debugging
5. In `Before launch`, add task building `.war` file.

Hot reloading is enabled in default (since it only changes the `.war` file and the container is up-to-date). If you need a cold boot, stop the `app` container first.

## Issues

Please submit issues through the *issue tracker* on GitHub.

## Credits

https://github.com/christianmetz/wildfly-mysql

https://github.com/pascalgrimaud/docker-jboss-as for JBoss AS

Released under the [MIT License](LICENSE).

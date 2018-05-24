# stack-docker
This example Docker Compose configuration includes Elasticsearch, Kibana and APM all running on a single machine under Docker. 
Based on [docker-elk repo](https://github.com/deviantony/docker-elk/tree/searchguard)

## Prerequisites
- Docker and Compose. Windows and Mac users get Compose installed automatically
with Docker. Linux users can:
```
pip install docker-compose
```

- At least 4GiB of RAM for the containers. Windows and Mac users _must_
configure their Docker virtual machine to have more than the default 2 GiB of
RAM:

![Docker VM memory settings](screenshots/docker-vm-memory-settings.png)

## Starting the stack
Try `docker-compose up` to create an Elastic Stack with
Elasticsearch, Kibana and APM.

Point a browser at [`http://localhost:5601`](http://localhost:5601) to see the results.

Log in with `admin` / `admin`.

**Note**: Has [Search Guard support](https://github.com/floragunncom/search-guard).

Based on the official Docker images:

* [elasticsearch](https://github.com/elastic/elasticsearch-docker)
* [APM](https://github.com/elastic/apm-server-docker)
* [kibana](https://github.com/elastic/kibana-docker)

Default configuration of Search Guard in this repo is:

* Basic authentication required to access Elasticsearch/Kibana
* HTTPS disabled
* Hostname verification disabled
* Self-signed SSL certificate for transport protocol (do not use in production)

**Check the [Demo users and roles](http://docs.search-guard.com/latest/demo-users-roles) 
and [Defining Roles and permissions](https://docs.search-guard.com/latest/roles-permissions) documentation pages 
for a list and description of the built-in Search Guard users.**

## Contents

1. [Requirements](#requirements)
   * [Host setup](#host-setup)
   * [SELinux](#selinux)
2. [Getting started](#getting-started)
   * [Bringing up the stack](#bringing-up-the-stack)
   * [Initial setup](#initial-setup)
3. [Configuration](#configuration)
   * [How can I tune the Kibana configuration?](#how-can-i-tune-the-kibana-configuration)
   * [How can I tune the APM configuration?](#how-can-i-tune-the-apm-configuration)
   * [How can I tune the Elasticsearch configuration?](#how-can-i-tune-the-elasticsearch-configuration)
   * [How can I scale out the Elasticsearch cluster?](#how-can-i-scale-up-the-elasticsearch-cluster)
4. [Storage](#storage)
   * [How can I persist Elasticsearch data?](#how-can-i-persist-elasticsearch-data)
5. [Extensibility](#extensibility)
   * [How can I add plugins?](#how-can-i-add-plugins)
   * [How can I enable the provided extensions?](#how-can-i-enable-the-provided-extensions)
6. [JVM tuning](#jvm-tuning)
   * [How can I specify the amount of memory used by a service?](#how-can-i-specify-the-amount-of-memory-used-by-a-service)
   * [How can I enable a remote JMX connection to a service?](#how-can-i-enable-a-remote-jmx-connection-to-a-service)

## Requirements

### Host setup

1. Install [Docker](https://www.docker.com/community-edition#/download) version **1.10.0+**
2. Install [Docker Compose](https://docs.docker.com/compose/install/) version **1.6.0+**
3. Clone this repository

### SELinux

On distributions which have SELinux enabled out-of-the-box you will need to either re-context the files or set SELinux
into Permissive mode in order for docker-elk to start properly. For example on Redhat and CentOS, the following will
apply the proper context:

```console
$ chcon -R system_u:object_r:admin_home_t:s0 docker-elk/
```

## Usage

### Bringing up the stack

Start the ELK stack using `docker-compose`:

```console
$ docker-compose up
```

You can also choose to run it in background (detached mode):

```console
$ docker-compose up -d
```

APM Server comes packaged with example Kibana dashboards, visualizations, and searches 
for visualizing APM Server data in Kibana. You can install them by:

```console
$ docker-compose exec -T apm_server apm-server setup --dashboards
```

_This executes sgadmin and loads the configuration from `elasticsearch/config/sg/sg*.yml`_

Give Kibana a few seconds to initialize, then access the Kibana web UI by hitting
[http://localhost:5601](http://localhost:5601) with a web browser and use the aforementioned credentials to login.

By default, the stack exposes the following ports:
* 8200: APM server TCP input.
* 5601: Kibana


## Initial setup

### Default Kibana index pattern creation

When Kibana launches for the first time, it is not configured with any index pattern.

#### Via the Kibana web UI

Refer to [Connect Kibana with
Elasticsearch](https://www.elastic.co/guide/en/kibana/current/connect-to-elasticsearch.html) for detailed instructions
about the index pattern configuration.

#### On the command line

Authenticate against Kibana:

```console
$ curl -XPOST -D- 'http://localhost:5601/api/v1/auth/login' \
    -c /tmp/sg_cookies \
    -H 'Content-Type: application/json' \
    -H 'kbn-version: 6.2.2' \
    -d '{"username":"kibanaro","password":"kibanaro"}'
```

Create an index pattern via the Kibana API:

```console
$ curl -XPOST -D- 'http://localhost:5601/api/saved_objects/index-pattern' \
    -b /tmp/sg_cookies \
    -H 'Content-Type: application/json' \
    -H 'kbn-version: 6.2.2' \
    -d '{"attributes":{"title":"apm-*","timeFieldName":"@timestamp"}}'
```

The created pattern will automatically be marked as the default index pattern as soon as the Kibana UI is opened for the first time.

## Configuration

**NOTE**: Configuration is not dynamically reloaded, you will need to restart the stack after any change in the
configuration of a component.

### How can I tune the Kibana configuration?

The Kibana default configuration is stored in `kibana/config/kibana.yml`.

It is also possible to map the entire `config` directory instead of a single file.

Some kibana docs here - https://www.elastic.co/guide/en/kibana/current/xpack-apm.html

### How can I tune the APM server configuration?

The APM configuration is stored in `apm-server/config/apm-server.yml`.

### How can I tune the Elasticsearch configuration?

The Elasticsearch configuration is stored in `elasticsearch/config/elasticsearch.yml`.

You can also specify the options you want to override directly via environment variables:

```yml
elasticsearch:

  environment:
    network.host: "_non_loopback_"
    cluster.name: "my-cluster"
```

### How can I scale out the Elasticsearch cluster?

Follow the instructions from the Wiki: [Scaling out
Elasticsearch](https://github.com/deviantony/docker-elk/wiki/Elasticsearch-cluster)

## Storage

### How can I persist Elasticsearch data?

The data stored in Elasticsearch will be persisted after container reboot but not after container removal.

In order to persist Elasticsearch data even after removing the Elasticsearch container, you'll have to mount a volume on
your Docker host. Update the `elasticsearch` service declaration to:

```yml
elasticsearch:

  volumes:
    - /path/to/storage:/usr/share/elasticsearch/data
```

This will store Elasticsearch data inside `/path/to/storage`.

**NOTE:** beware of these OS-specific considerations:
* **Linux:** the [unprivileged `elasticsearch` user][esuser] is used within the Elasticsearch image, therefore the
  mounted data directory must be owned by the uid `1000`.
* **macOS:** the default Docker for Mac configuration allows mounting files from `/Users/`, `/Volumes/`, `/private/`,
  and `/tmp` exclusively. Follow the instructions from the [documentation][macmounts] to add more locations.

[esuser]: https://github.com/elastic/elasticsearch-docker/blob/016bcc9db1dd97ecd0ff60c1290e7fa9142f8ddd/templates/Dockerfile.j2#L22
[macmounts]: https://docs.docker.com/docker-for-mac/osxfs/

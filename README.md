# Docker Image with InfluxDB and Grafana

![license](https://img.shields.io/github/license/warcry98/influxdb-grafana-docker)

![Grafana][grafana-version] ![Influx][influx-version]

This is a Docker image based on the awesome [Docker Image with Telegraf (StatsD), InfluxDB and Grafana](https://github.com/samuelebistoletti/docker-statsd-influxdb-grafana) from [Samuele Bistoletti](https://github.com/samuelebistoletti).

The main point of difference with this image is:

* Persistence is supported via mounting volumes to a Docker container
* Grafana will store its data in SQLite files instead of a MySQL table on the container, so MySQL is not installed
* Telegraf (StatsD) is not included in this container


| Description  | Value   |
|--------------|---------|
| InfluxDB     | 2.3.0   |
| Grafana      | 9.0.6   |

## Quick Start

To start the container with persistence you can use the following:

```sh
docker-compose build
```

To stop the container launch:

```sh
docker-compose down
```

To start the container again launch:

```sh
docker-compose up -d
```

## Mapped Ports

```
Host		Container		Service

3003		3003			grafana
8086		8086			influxdb
```
## SSH

```sh
docker exec -it <CONTAINER_ID> bash
```

## Grafana

Open <http://localhost:3003>


### Add data source on Grafana

1. Using the wizard click on `Add data source`
2. Choose a `name` for the source and flag it as `Default`
3. Choose `InfluxDB` as `type`
4. Choose `direct` as `access`
5. Fill remaining fields as follows and click on `Add` without altering other fields

Basic auth and credentials must be left unflagged. Proxy is not required.

Now you are ready to add your first dashboard and launch some queries on a database.

## InfluxDB

### Web Interface

Open <http://localhost:8086>


### InfluxDB Shell (CLI)

1. Establish a ssh connection with the container
2. Launch `influx` to open InfluxDB Shell (CLI)

[grafana-version]: https://img.shields.io/badge/Grafana-9.0.6-brightgreen
[influx-version]: https://img.shields.io/badge/Influx-2.3.0-brightgreen

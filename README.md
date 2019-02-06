# Mapserver WMS OGR

## TL;DR

```docker
docker build -t pdok/mapserver-wms-ogr .
docker run -e MS_MAPFILE=/srv/data/example.map -d -p 80:80 --name mapserver-example -v /path/on/host:/srv/data pdok/mapserver-wms-ogr

docker stop mapserver-example
docker rm mapserver-example
```

## Introduction

This project aims to fulfill two needs:

1. create a [OGC services](http://www.opengeospatial.org/standards) that are deployable on a scalable infrastructure.
2. create a useable [Docker](https://www.docker.com) base image.

Fulfilling the first need the main purpose is to create an Docker base image that eventually can be run on a platform like [Kubernetes](https://kubernetes.io/).

Regarding the second need, finding a usable Mapserver Docker image is a challenge. Most images expose the &map=... QUERY_STRING in the getcapabilities, don't run in fastcgi and are based on Apache.

## What will it do

It will create an WMS-only Mapserver application run with a lightweight web application Lighttpd in which the map=.. QUERY_STRING issue is fixed. The application is configured for service raster files (GeoTIFF)

## Components

This stack is composed of the following:

* [Mapserver](http://mapserver.org/)
* [OGR2OGR](http://www.gdal.org/ogr2ogr.html)
* [Lighttpd](https://www.lighttpd.net/)

### Mapserver

Mapserver is the platform that will provide the WMS services based on a raster datasource.

### OGR2OGR

For transforming simple features from a data store to WFS features.

### Lighttpd

Lighttpd is the web server we use to run Mapserver as a fastcgi web application.

## Docker image

The Docker image contains 2 stages:

1. builder
2. service

### builder

The builder stage compiles Mapserver. The Dockerfile contains all the available Mapserver build option explicitly, so it is clear which options are enabled and disabled.

### service

The service stage copies the Mapserver, build in the first stage, and configures Lighttpd.

## Usage

### Build

```docker
docker build -t pdok/mapserver-wms-ogr .
```

### Run

This image can be run straight from the commandline. A volumn needs to be mounted on the container directory /srv/data. The mounted volumn needs to contain at least one mapserver *.map file. The name of the mapfile will determine the URL path for the service.

```docker
docker run -d -p 80:80 --name mapserver-run-example -v /path/on/host:/srv/data pdok/mapserver-wms-ogr
```

The prefered way to use it is as a Docker base image for an other Dockerfile, in which the necessay files are copied into the right directory (/srv/data)

```docker
FROM pdok/mapserver-wms-ogr

ENV MS_MAPFILE /srv/data/example.map

COPY /etc/example.map /srv/data/example.map
```

Running the example above will create a service on the url <http://localhost/?request=getcapabilities&service=wcs>

The ENV variables that can be set are:

* DEBUG
* MIN_PROCS
* MAX_PROCS
* MAX_LOAD_PER_PROC
* IDLE_TIMEOUT
* MS_MAPFILE

The ENV variables, with the exception of MS_MAPFILE have a default value set in the Dockerfile.

```docker
docker run -e DEBUG=0 -e MIN_PROCS=1 -e MAX_PROCS=3 -e MAX_LOAD_PER_PROC=4 -e IDLE_TIMEOUT=20 -e MS_MAPFILE=/srv/data/example.map -d -p 80:80 --name mapserver-run-example -v /path/on/host:/srv/data pdok/mapserver-wms-postgis
```

## Misc

### Why no WFS

If one wants a OGC WFS service, then we have our pdok/mapserver-wfs-postgis image. So why are those (WFS and WMS) seperated? We regard both service as completly different. 
Regarding microservices it is logical to split those from each other. Also in our experience we have run to often into issues that the same data is exposed as a WMS and WFS.

### Why Lighttpd

In our previous configurations we would run NGINX, while this is a good webservice and has a lot of configuration options, it runs with multiple processes. There for we needed supervisord for managing this, whereas Lighthttpd runs as a single proces. Also all the routing configuration options aren't needed, because that is handled by the infrastructure/platform, like Kubernetes. If one would like to configure some simple routing is still can be done in the lighttpd.conf.

### Used examples

* <https://github.com/srounet/docker-mapserver>
* <https://github.com/Amsterdam/mapserver>

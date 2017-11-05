#!/usr/bin/env bash

MODE=$1

BASE_DIR=$(cd `dirname $0` && pwd -P)

docker -H unix:///var/run/bootstrap.sock run --net=host -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/bootstrap.sock:/var/run/bootstrap.sock \
        -e DOCKER_HOST=unix:///var/run/bootstrap.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e MODE=${MODE} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*

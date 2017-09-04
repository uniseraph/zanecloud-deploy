#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0` && pwd -P)

REGION_ID=$(curl -fsL 100.100.100.200/latest/meta-data/region-id)
INSTANCE_ID=$(curl -fsL  100.100.100.200/latest/meta-data/instance-id)


docker -H unix:///var/run/bootstrap.sock run --net=host -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/bootstrap.sock:/var/run/bootstrap.sock \
        -e DOCKER_HOST=unix:///var/run/bootstrap.sock  \
        -e REGION_ID=${REGION_ID} \
	    -e ACCESS_KEY_ID=${ACCESS_KEY_ID}  \
	    -e ACCESS_KEY_SECRET=${ACCESS_KEY_SECRET} \
	    -e INSTANCE_ID=${INSTANCE_ID} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*

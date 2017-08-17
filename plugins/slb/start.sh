#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0` && pwd -P)

REGION=$(curl -fsL 100.100.100.200/latest/meta-data/region-id)
INSTANCE_ID=$(curl -fsL  100.100.100.200/latest/meta-data/instance-id)


docker run --net=host -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e REGION=${REGION} \
	    -e ACCESS_KEY_ID=${ßACCESS_KEY_ID}  \
	    -e SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY} \
	    -e INSTANCE_ID=${INSTANCE_ID} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*

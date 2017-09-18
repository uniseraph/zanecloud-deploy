#!/usr/bin/env bash


BASE_DIR=$(cd `dirname $0` && pwd -P)

ES_NAME="es0"

MASTER_IP=${MASTER_IP:-${LOCAL_IP}}


cp -f plugins/elk/logstash/pipeline.conf.template plugins/elk/logstash/pipeline.conf

sed -i -e "s#localhost#${MASTER_IP}#g" plugins/elk/logstash/pipeline.conf

docker  -H unix:///var/run/bootstrap.sock run --net=host -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/bootstrap.sock:/var/run/bootstrap.sock \
	    -e DOCKER_HOST=unix:///var/run/bootstrap.sock \
        -e LOCAL_IP=${LOCAL_IP} \
        -e MASTER_IP=${MASTER_IP} \
        -e ES_NAME=${ES_NAME} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*

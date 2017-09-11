#!/usr/bin/env bash


BASE_DIR=$(cd `dirname $0` && pwd -P)




ES_NAME="es0"



MASTER_IP=${MASTER_IP:-${LOCAL_IP}}


#DIS_URL=${DIS_URL:-"zk://${MASTER0_IP}:2181,${MASTER1_IP}:2181,${MASTER2_IP}:2181/default"}

#HOSTNAME=`hostname`

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

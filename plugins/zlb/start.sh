#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0` && pwd -P)


docker -H unix:///var/run/bootstrap.sock run --net=host -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/bootstrap.sock:/var/run/bootstrap.sock \
        -e DOCKER_HOST=unix:///var/run/bootstrap.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*


if [[ ${PROVIDER} == "aws" ]]; then
    LB_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
    if [[ -z ${LB_IP} ]]; then
        LB_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
    fi
elif  [[ ${PROVIDER} == "aliyun" ]]; then
    LB_IP=$(curl http://100.100.100.200/latest/meta-data/eipv4)
    if [[ -z ${LB_IP} ]]; then
        LB_IP=$(curl http://100.100.100.200/latest/meta-data/local-ipv4)
    fi
elif  [[ ${PROVIDER} == "native" ]]; then
    LB_IP=${LOCAL_IP}
else
   echo "no such provider ${PROVIDER}"
   exit
fi

cp -f plugins/zlb/zlb-api.json.template plugins/zlb/zlb-api.json

sed -i -e "s#localhost#${LB_IP}#g" plugins/zlb/zlb-api.json

curl -H "Content-Type: application/json" -X POST -d @plugins/zlb/zlb-api.json http://127.0.0.1:6400/services/create
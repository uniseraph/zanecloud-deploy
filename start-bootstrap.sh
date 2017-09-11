#!/usr/bin/env bash

ETCD_NAME="etcd0"

ZK_URL=${ZK_URL:-"zk://${MASTER_IP}:2181"}
BOOTSTRAP_EXPECT=${BOOTSTRAP_EXPECT:-1}
FLANNEL_NETWORK=${FLANNEL_NETWORK:-"192.168.0.0/16"}

if [[ ! -f /etc/dnsmasq.resolv.conf ]]; then
    cp -f /etc/resolv.conf /etc/dnsmasq.resolv.conf
fi

DNS_SERVERS=$( cat /etc/dnsmasq.resolv.conf | grep nameserver | awk '{{print $2}}' | xargs -n 1 printf "-S %-10s "  )



docker -H unix:///var/run/bootstrap.sock run --net=host -ti --rm -v $(pwd):$(pwd) \
	    -v /var/run/bootstrap.sock:/var/run/bootstrap.sock \
        -v /usr/bin/docker:/usr/bin/docker \
        -e DOCKER_HOST=unix:///var/run/bootstrap.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e MASTER_IP=${MASTER_IP} \
        -e ETCD_NAME=${ETCD_NAME} \
        -e BOOTSTRAP_EXPECT=${BOOTSTRAP_EXPECT} \
        -e DNS_SERVERS="${DNS_SERVERS}" \
        -w $(pwd)  \
        docker/compose:1.9.0 \
        -f compose/bootstrap.yml \
        -p bootstrap \
        up -d $*




  SECONDS=0
  while [[ $(curl -fsSL http://${LOCAL_IP}:2379/health 2>&1 1>/dev/null; echo $?) != 0 ]]; do
    ((SECONDS++))
    if [[ ${SECONDS} == 99 ]]; then
      echo "etcd failed to start. Exiting..."
      exit 1
    fi
    sleep 1
  done

  curl -sSL http://${LOCAL_IP}:2379/v2/keys/coreos.com/network/config -XPUT \
      -d value="{ \"Network\": \"${FLANNEL_NETWORK}\",  \"SubnetLen\":25    ,   \"Backend\": {\"Type\": \"vxlan\"}}"

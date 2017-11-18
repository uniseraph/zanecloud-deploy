#!/usr/bin/env bash



MAIN_DEV=${MAIN_DEV:-"eth0"}



TYPE=swarm
WITH_CADVISOR=false
WITH_HDFS=false
WITH_YARN=false
WITH_ELK=false
WITH_EBK=false
WITH_ZLB=false
WITH_ELBV2=false
WITH_SLB=false
LB=none


ARGS=`getopt -a -o T: -l type:,with-cadvisor,with-yarn,with-elk,with-ebk,with-hdfs,with-elbv2,with-slb,with-zlb,help -- "$@" `
[ $? -ne 0 ] && usage
#set -- "${ARGS}"
eval set -- "${ARGS}"
while true
do
        case "$1" in
        -T|--type)
                TYPE="$2"
                shift
                ;;
        --with-cadvisor)
                WITH_CADVISOR=true
                ;;
        --with-hdfs)
                WITH_HDFS=true
                ;;
        --with-elk)
                WITH_ELK=true
                ;;
        --with-ebk)
                WITH_EBK=true
                ;;
        --with-yarn)
                WITH_YARN=true
                ;;
        --with-zlb)
                WITH_ZLB=true
                LB=zlb
                ;;
         --with-elbv2)
                WITH_ELBV2=true
                LB=elbv2
                ;;
        --with-slb)
                WITH_SLB=true
                LB=slb
                ;;
        -h|--help)
                usage
                ;;
        --)
                shift
                break
                ;;
        esac
shift
done


echo "TYPE=${TYPE}"
echo "WITH_CADVISOR=${WITH_CADVISOR}"
echo "WITH_YARN=${WITH_YARN}"
echo "WITH_HDFS=${WITH_HDFS}"
echo "WITH_ELK=${WITH_ELK}"
echo "WITH_ELK=${WITH_EBK}"
echo "WITH_ZLB=${WITH_ZLB}"
echo "WITH_ELBV2=${WITH_ELBV2}"
echo "WITH_SLB=${WITH_SLB}"
echo "LB=${LB}"
export LB
if type apt-get >/dev/null 2>&1; then
  echo 'using apt-get '
  export LOCAL_IP=$(ifconfig ${MAIN_DEV} | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}')
elif type yum >/dev/nul 2>&1; then
  export LOCAL_IP=$(ifconfig ${MAIN_DEV} | grep -P "inet\s+" | awk '{{print $2}}' )
else
  echo "no apt-get and no yum, exit"
  exit
fi

MASTER_IP=${MASTER_IP:-$LOCAL_IP}

bash -x init-node.sh

if [[ ${TYPE} == "mesos" ]]; then

    bash -x start-bootstrap.sh  etcd zookeeper dnsmasq flanneld consul-server  && \
    bash -x start-docker.sh

    bash -x start-mesos.sh master slave

    if [[ ${LOCAL_IP} == ${MASTER0_IP} ]]; then
        bash -x start-mesos.sh marathon mesos-consul
        echo "marathon starting success ......, Please access http://${LOCAL_IP}:8080"
    fi
elif [[ ${TYPE} == "swarm" ]]; then
    bash -x start-bootstrap.sh  etcd  dnsmasq flanneld consul-server  && \
    bash -x start-docker.sh

    MODE=docker-compose bash -x plugins/watchdog/start.sh
    bash -x plugins/metad/start.sh
    bash -x plugins/tunneld/start.sh

    bash -x plugins/swarm/start.sh  master agent

elif [[ ${TYPE} == "kubernetes" ]]; then
    bash -x start-bootstrap.sh  etcd  dnsmasq flanneld consul-server  && \
    bash -x start-docker.sh

    bash -x plugins/kubernetes/init-kubernetes.sh
    bash -x plugins/kubernetes/start-master.sh
    bash -x plugins/kubernetes/start-worker.sh

elif [[ ${TYPE} == "none" ]]; then
    bash -x start-bootstrap.sh  etcd  dnsmasq flanneld consul-server  && \
    bash -x start-docker.sh

    MODE=name bash -x plugins/watchdog/start.sh
else
    echo  "No such cluster type:${TYPE}"
    exit -1
fi

if [[ ${WITH_EBK} == true ]]; then
    bash -x plugins/elk/start.sh  kibana elasticsearch
fi

if [[ ${WITH_ELBV2} == true ]]; then
    bash -x plugins/elbv2/start.sh
fi

if [[ ${WITH_SLB} == true ]]; then
    bash -x plugins/slb/start.sh
fi


if [[ ${WITH_ELK} == true ]]; then
    bash -x plugins/elk/start.sh logspout logstash  kibana elasticsearch
fi


if [[ ${WITH_ZLB} == true ]]; then
    bash -x plugins/zlb/start.sh watchdog zlb zlb-api
fi

if [[ ${WITH_EBK} == true ]]; then
    bash -x plugins/beats/start.sh
fi

echo "nameserver 127.0.0.1" > /etc/resolv.conf

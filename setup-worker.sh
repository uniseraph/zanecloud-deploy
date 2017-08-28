#!/usr/bin/env bash


if [[ -z ${MASTER0_IP} ]]; then
    echo "Please export MASTER0_IP in your env"
    exit 1
fi

if [[ -z ${MASTER1_IP} ]]; then
    echo "Please export MASTER1_IP in your env"
    exit 1
fi

if [[ -z ${MASTER2_IP} ]]; then
    echo "Please export MASTER2_IP in your env"
    exit 1
fi

if [[ -z ${PROVIDER} ]]; then
    echo "using default provider:aliyun"
    export PROVIDER="aliyun"
fi



TYPE=mesos
WITH_CADVISOR=false
WITH_HDFS=false
WITH_YARN=false
WITH_ELK=false
WITH_EBK=false
WITH_ELBV2=false
WITH_SLB=false

ARGS=`getopt -a -o T: -l type:,with-cadvisor,with-yarn,with-elk,with-ebk,with-hdfs,with-elbv2,with-slb,help -- "$@" `
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
        --with-elk)
                WITH_ELK=true
                ;;
        --with-elk)
                WITH_EBK=true
                ;;
        --with-hdfs)
                WITH_HDFS=true
                ;;
        --with-yarn)
                WITH_YARN=true
                ;;
        --with-elbv2)
                WITH_ELBV2=true
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
echo "WITH_ELBV2=${WITH_ELBV2}"
echo "WITH_SLB=${WITH_SLB}"


if type apt-get >/dev/null 2>&1; then
  echo 'using apt-get '
  sudo apt-get update && apt-get install -y jq  bridge-utils tcpdump  haveged strace pstack htop  curl wget  iotop blktrace   dstat ltrace lsof
  export LOCAL_IP=$(ifconfig eth0 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}')

elif type yum >/dev/nul 2>&1; then
  echo 'using yum'
  sudo yum install -y  jq bind-utils bridge-utils tcpdump  haveged strace pstack htop iostat vmstat curl wget sysdig pidstat mpstat iotop blktrace perf  dstat ltrace lsof

  export LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}' )

else
  echo "no apt-get and no yum, exit"
  exit
fi


bash -x init-node.sh  && \
    bash -x start-bootstrap.sh  dnsmasq flanneld consul-agent  && \
    bash -x start-docker.sh



if [[ ${TYPE} == "mesos" ]]; then
    bash -x start-mesos.sh  slave
elif [[ ${TYPE} == "swarm" ]]; then
    export DIS_URL="consul://127.0.0.1:8500/default"

    bash -x plugins/swarm/start.sh agent
    bash -x plugins/watchdog/start.sh
elif [[ ${TYPE} == "kubernetes" ]]; then

    bash -x plugins/kubernetes/start-worker.sh


else
    echo  "No such cluster type:${TYPE}"
    exit -1
fi

if [[ ${WITH_ELBV2} == true ]]; then
    bash -x plugins/elbv2/start.sh
fi
if [[ ${WITH_ELBV2} == true ]]; then
    bash -x plugins/slb/start.sh
fi

if [[ ${WITH_ELK} == true ]]; then
    bash -x plugins/elk/start.sh logspout logstash
fi


if [[ ${WITH_EBK} == true ]]; then
    bash -x plugins/beats/start.sh
fi


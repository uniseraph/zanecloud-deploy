#!/usr/bin/env bash


if type apt-get >/dev/null 2>&1; then
  echo 'using apt-get '
  sudo systemctl stop docker
#  sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
#  sudo cp ./apt/sources.list /etc/apt/sources.list
  sudo apt-get remove -y docker.engine
  sudo systemctl unmask docker
  sudo systemctl unmask docker.socket
  sudo rm -rf /etc/init.d/docker
  sudo rm -rf /etc/docker/key.json  #aws的镜像可能残留docker的key.json，会导致swarm node ID dup
  sudo apt-get update && apt-get install -y git jq  bridge-utils tcpdump  haveged strace pstack htop  curl wget  iotop blktrace   dstat ltrace lsof

elif type yum >/dev/nul 2>&1; then
  echo 'using yum'
  sudo yum install -y git jq bind-utils bridge-utils tcpdump  haveged strace  htop   curl wget    iotop blktrace perf  dstat ltrace lsof

else
  echo "no apt-get and no yum, exit"
  exit
fi



echo "net.ipv4.etc.eth0.rp_filter=0" > /etc/sysctl.d/omega.conf

sysctl -w net.ipv4.conf.eth0.rp_filter=0
sysctl -w vm.max_map_count=262144

cp sysctl.conf /etc/sysctl.conf
sysctl -p


modprobe overlay
cp -f zanecloud.conf /etc/modules-load.d/zanecloud.conf

if [[ ! -d binary  ]] ; then
      mkdir -p binary
      wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-1.11.1   -O docker -P binary
      wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd   -P binary
      wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd-ctr  -P binary
      wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd-shim  -P binary
      wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-runc  -P binary
fi



sudo chmod +x binary/*
sudo cp -f  binary/* /usr/bin/


sudo mkdir -p /etc/sysconfig

systemctl unmask docker.service
systemctl unmask docker.socket
cp -f systemd/docker-1.11/docker.service /etc/systemd/system/
cp -f systemd/docker-1.11/docker.socket /etc/systemd/system/

cp -f systemd/bootstrap/bootstrap.service /etc/systemd/system/
cp -f systemd/bootstrap/bootstrap.socket /etc/systemd/system/
cp -f systemd/bootstrap/bootstrap /etc/sysconfig/bootstrap

systemctl daemon-reload
systemctl restart docker
systemctl restart bootstrap
systemctl enable bootstrap


if [[  -f image.tar ]] ; then
      docker -H unix:///var/run/bootstrap.sock load -i image.tar
fi

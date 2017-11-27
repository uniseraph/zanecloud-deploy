# Copyright (c) 2015-2017, ANT-FINANCE CORPORATION. All rights reserved.

SHELL = /bin/bash


VERSION = $(shell cat VERSION)
GITCOMMIT = $(shell git log -1 --pretty=format:%h)
BUILD_TIME = $(shell date --rfc-3339 ns 2>/dev/null | sed -e 's/ /T/')

DOCKER_GITCOMMIT=d349391

release:
	rm -rf release && mkdir -p release/zanecloud-deploy
	cp -r plugins release/zanecloud-deploy
	cp -r compose release/zanecloud-deploy
	cp -r systemd release/zanecloud-deploy
	cp *.conf release/zanecloud-deploy
	cp *.conf.template release/zanecloud-deploy
	cp *.sh release/zanecloud-deploy
	cd release && tar zcvf zanecloud-deploy-${VERSION}-${GITCOMMIT}.tar.gz  zanecloud-deploy && cd ..



release-withdeps:
	rm -rf release && mkdir -p release/zanecloud-deploy
	cp -r plugins release/zanecloud-deploy
	cp -r compose release/zanecloud-deploy
	cp -r systemd release/zanecloud-deploy
	cp *.conf release/zanecloud-deploy
	cp *.conf.template release/zanecloud-deploy
	cp *.sh release/zanecloud-deploy
	mkdir -p release/zanecloud-deploy/binary && \
	    wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-1.11.1   -O release/zanecloud-deploy/binary/docker   && \
        wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd  -P release/zanecloud-deploy/binary  && \
        wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd-ctr  -P release/zanecloud-deploy/binary  && \
        wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd-shim   -P release/zanecloud-deploy/binary  && \
        wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-runc  -P release/zanecloud-deploy/binary && \
        wget http://zanecloud-others.oss-cn-beijing.aliyuncs.com/metricbeat-5.5.1-x86_64.rpm  -P release/zanecloud-deploy/binary && \
        wget http://zanecloud-others.oss-cn-beijing.aliyuncs.com/filebeat-5.5.1-x86_64.rpm  -P release/zanecloud-deploy/binary  && \
        wget  http://zanecloud-others.oss-cn-beijing.aliyuncs.com/beats-dashboards-5.5.1.zip -P release/zanecloud-deploy/binary
	docker pull registry.cn-hangzhou.aliyuncs.com/zanecloud/watchdog:0.2.0-99ca0c8 && \
	  docker pull swarm:1.2.6 && \
	  docker pull registry.cn-hangzhou.aliyuncs.com/zanecloud/tunneld:0.1.0-81e006c && \
	  docker pull registry.cn-hangzhou.aliyuncs.com/zanecloud/metad:0.1.0 && \
    docker pull registry.cn-hangzhou.aliyuncs.com/omega-reg/flannel:v0.7.1-amd64 && \
    docker pull registry.cn-hangzhou.aliyuncs.com/omega-reg/etcd:3.1.7 && \
    docker pull andyshinn/dnsmasq:2.75 && \
    docker pull consul:0.7.5 && \
    docker pull docker/compose:1.9.0 && \
    docker pull registry.cn-hangzhou.aliyuncs.com/zanecloud/zlb:1.0.3-4d1e2ef && \
    docker pull registry.cn-hangzhou.aliyuncs.com/zanecloud/zlb-api:0.1.1-afb9c74 && \
    docker pull registry.cn-hangzhou.aliyuncs.com/zanecloud/kibana:5.4.0 && \
    docker pull registry.cn-hangzhou.aliyuncs.com/zanecloud/elasticsearch:5.4.0 && \
    docker pull registry.cn-hangzhou.aliyuncs.com/zanecloud/logstash:5.4.0
	docker save -o release/zanecloud-deploy/image.tar registry.cn-hangzhou.aliyuncs.com/zanecloud/watchdog:0.2.0-99ca0c8  \
            swarm:1.2.6  \
            registry.cn-hangzhou.aliyuncs.com/zanecloud/tunneld:0.1.0-81e006c  \
            registry.cn-hangzhou.aliyuncs.com/zanecloud/metad:0.1.0  \
            registry.cn-hangzhou.aliyuncs.com/omega-reg/flannel:v0.7.1-amd64  \
            registry.cn-hangzhou.aliyuncs.com/omega-reg/etcd:3.1.7 \
            andyshinn/dnsmasq:2.75  \
            consul:0.7.5 \
            docker/compose:1.9.0 \
            registry.cn-hangzhou.aliyuncs.com/zanecloud/zlb-api:0.1.1-afb9c74 \
            registry.cn-hangzhou.aliyuncs.com/zanecloud/kibana:5.4.0 \
            registry.cn-hangzhou.aliyuncs.com/zanecloud/elasticsearch:5.4.0 \
            registry.cn-hangzhou.aliyuncs.com/zanecloud/logstash:5.4.0 \
	    registry.cn-hangzhou.aliyuncs.com/zanecloud/zlb:1.0.3-4d1e2ef
	cd release && tar zcvf zanecloud-deploy-withdeps-${VERSION}-${GITCOMMIT}.tar.gz  zanecloud-deploy && cd ..


.PHONY: release

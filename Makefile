# Copyright (c) 2015-2017, ANT-FINANCE CORPORATION. All rights reserved.

SHELL = /bin/bash


VERSION = $(shell cat VERSION)
GITCOMMIT = $(shell git log -1 --pretty=format:%h)
BUILD_TIME = $(shell date --rfc-3339 ns 2>/dev/null | sed -e 's/ /T/')


release:
	rm -rf release && mkdir -p release/zanecloud-deploy
	cp -r plugins release/zanecloud-deploy
	cp -r compose release/zanecloud-deploy
	cp -r systemd release/zanecloud-deploy
	cp *.conf release/zanecloud-deploy
	cp *.sh release/zanecloud-deploy
	cd release && tar zcvf zanecloud-deploy-${VERSION}-${GITCOMMIT}.tar.gz  zanecloud-deploy && cd ..



.PHONY: release

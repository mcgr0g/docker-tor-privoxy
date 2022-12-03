# VERSIONS ---------------------------------------------------------------------
IMG_VER=0.1.3
IMG_NAME=mcgr0g/talpa-altaica
BUILD_DATE:=$(shell date '+%Y-%m-%d')

GOLANG_VER=1.18
ALPINE_VER=3.17
SQUID_VER=5.7-r0
TOR_VER=0.4.7.10-r0
SNOWFLAKE_VER=v2.4.0

# BUILD FLAGS -----------------------------------------------------------------

BFLAGS=docker build \
		--build-arg img_ver=$(IMG_VER) \
		--build-arg build_date=$(BUILD_DATE) \
		--build-arg golang_ver=$(GOLANG_VER) \
		--build-arg alpine_ver=$(ALPINE_VER) \
		--build-arg squid_ver=$(SQUID_VER) \
		--build-arg tor_ver=$(TOR_VER) \
		--build-arg snowflake_ver=$(SNOWFLAKE_VER) \
		-t $(IMG_NAME):$(IMG_VER)

BUILD_FAST=$(BFLAGS) .
BUILD_FULL=$(BFLAGS) --no-cache .
UPGRAGE_PKGS=$(BFLAGS) --build-arg UPGRADE=true .
RECONF=$(BFLAGS) --build-arg RECONFIGURED=true .
SNOWONLY=$(BFLAGS) --target build-env-snowflake .

# IMAGE -----------------------------------------------------------------------

build:
	$(BUILD_FAST)
	
build-full:
	$(BUILD_FULL)

upgrade packages:
	$(UPGRAGE_PKGS)

reconf:
	$(RECONF)

# stop after build stage "build-env-snowflake"
# you can get and test binaries on other host
snowflake:
	$(SNOWONLY)

login:
	docker login

prepush:
	docker tag $(IMG_NAME):$(IMG_VER) $(IMG_NAME):latest

# First need to login.
push:
	docker push $(IMG_NAME)

pull:
	docker pull $(IMG_NAME)

# CONTAINER -------------------------------------------------------------------

example:
	docker run --rm --name torproxy \
	-e IP_CHANGE_SECONDS=120 \
	-e EXIT_NODE={ua},{ug},{uk},{ie} \
	-p 127.0.0.1:8888:8888 \
	-p 127.0.0.1:9050:9050 \
	$(IMG_NAME):$(IMG_VER)

run:
	docker run --rm --name torproxy \
	-e EXCLUDE_NODE={RU},{UA},{AM},{KG},{BY} \
	-p 127.0.0.1:8888:8888 \
	-p 127.0.0.1:9050:9050 \
	$(IMG_NAME):$(IMG_VER)

container-flop:
	docker container run -it $(IMG_NAME):$(IMG_VER) /bin/bash

runner-flop:
	docker exec -it torproxy /bin/sh
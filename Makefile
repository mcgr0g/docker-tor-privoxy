VERSION=0.1.0
IMAGE=mcgr0g/talpa-altaica

# IMAGE -----------------------------------------------------------------------

build:
	docker build -t $(IMAGE):$(VERSION) .

build-full:
	docker build --no-cache -t $(IMAGE):$(VERSION) .

upgrade packages:
	docker build --build-arg UPGRADE=true -t $(IMAGE):$(VERSION) .

reconf:
	docker build --build-arg RECONFIGURED=true -t $(IMAGE):$(VERSION) .

snowflake:
	docker build --target build-env-snowflake -t $(IMAGE):$(VERSION) .

login:
	docker login

prepush:
	docker tag $(IMAGE):$(VERSION) $(IMAGE):latest

# First need to login.
#
push:
	docker push $(IMAGE)

pull:
	docker pull $(IMAGE)

# CONTAINER -------------------------------------------------------------------

example:
	docker run --rm --name torproxy \
	-e IP_CHANGE_SECONDS=120 \
	-e EXIT_NODE={ua},{ug},{uk},{ie} \
	-p 127.0.0.1:8888:8888 \
	-p 127.0.0.1:9050:9050 \
	$(IMAGE):$(VERSION)

run:
	docker run --rm --name torproxy \
	-e EXCLUDE_NODE={RU},{UA},{AM},{KG},{BY} \
	-p 127.0.0.1:8888:8888 \
	-p 127.0.0.1:9050:9050 \
	$(IMAGE):$(VERSION)

container-flop:
	docker container run -it $(IMAGE):$(VERSION) /bin/bash

runner-flop:
	docker exec -it torproxy /bin/sh
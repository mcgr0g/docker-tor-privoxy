VERSION=0.0.6
IMAGE=mcgr0g/tor-privoxy

# IMAGE -----------------------------------------------------------------------

build:
	docker build -t $(IMAGE) -t $(IMAGE):$(VERSION) .

login:
	docker login

# First need to login.
#
push:
	docker push $(IMAGE)

pull:
	docker pull $(IMAGE)

# CONTAINER -------------------------------------------------------------------

run:
	docker run --rm --name tor \
	-e IP_CHANGE_SECONDS=120 \
	-e EXIT_NODE={ua},{ug},{uk},{ie} \
	-p 127.0.0.1:8888:8888 \
	-p 127.0.0.1:9050:9050 \
	$(IMAGE):$(VERSION)

sample:
	docker run --rm --name torproxy \
	-e EXCLUDE_NODE={RU},{UA},{AM},{KG},{BY} \
	-p 127.0.0.1:8888:8888 \
	-p 127.0.0.1:9050:9050 \
	$(IMAGE):$(VERSION)
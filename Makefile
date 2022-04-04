VERSION=0.0.7
IMAGE=mcgr0g/talpa-altaica

# IMAGE -----------------------------------------------------------------------

build:
	docker build --no-cache -t $(IMAGE):$(VERSION) .

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
	docker run --rm --name torproxy \
	-e IP_CHANGE_SECONDS=120 \
	-e EXIT_NODE={ua},{ug},{uk},{ie} \
	-p 127.0.0.1:8888:8888 \
	-p 127.0.0.1:9050:9050 \
	$(IMAGE):$(VERSION)

dash:
	docker run --rm --name torproxy \
	-e EXCLUDE_NODE={RU},{UA},{AM},{KG},{BY} \
	-p 127.0.0.1:8888:8888 \
	-p 127.0.0.1:9050:9050 \
	$(IMAGE):$(VERSION)
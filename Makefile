IMAGE_NAME = rdma-tcpdump

all: build

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run --rm --privileged --network host -it $(IMAGE_NAME)

.PHONY: all build run

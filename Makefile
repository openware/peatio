IMAGE_NAME := peatio
RUBY_VERSION := 2.2.1

build:
	docker build -t $(IMAGE_NAME) --build-arg RUBY_VERSION=$(RUBY_VERSION) .

run:
	docker run -it --rm -v $(PWD):/home/web -e RAILS_ENV=$(RAILS_ENV) -u $(shell id -u) --privileged --net host $(IMAGE_NAME) bash

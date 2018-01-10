VERSION ?= $(shell cat VERSION)
ENV     ?= staging
SERVICE := barong
IMAGE   := gcr.io/helios-stage/barong:$(VERSION)
CURRENT_CONTEXT := $(shell kubectl config current-context)

.PHONY: default build push run ci deploy

default: build run

build:
	@echo '> Using ENV: $(ENV) and context: $(CURRENT_CONTEXT)'
	@echo '> Building "$(SERVICE)" docker image...'
	@docker build -t $(IMAGE) .

push: build
	gcloud docker -- push $(IMAGE)

run:
	@echo '> Starting "$(SERVICE)" container...'
	@docker run -d $(IMAGE)

ci:
	@fly -t ci set-pipeline -p $(SERVICE) -c config/pipelines/review.yml -n
	@fly -t ci unpause-pipeline -p $(SERVICE)

deploy:
	@helm install ./config/charts/$(SERVICE) --set "image.tag=$(VERSION)"

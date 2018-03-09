VERSION ?= $(shell cat VERSION)
ENV     ?= staging
SERVICE := barong
IMAGE   := rubykube/$(SERVICE):$(VERSION)
CURRENT_CONTEXT := $(shell kubectl config current-context)

.PHONY: default build push run ci deploy

default: build run

build:
	@echo '> Using ENV: $(ENV) and context: $(CURRENT_CONTEXT)'
	@echo '> Building "$(SERVICE)" docker image...'
	@docker build -t $(IMAGE) .

push: build
	@docker push $(IMAGE)

run:
	@echo '> Starting "$(SERVICE)" container...'
	@docker run -d --name=database -e MYSQL_ALLOW_EMPTY_PASSWORD=true -p 13306:13306 mysql
	@docker run --link=database -e DATABASE_HOST=database -p 3000:3000 -d $(IMAGE)

ci:
	@fly -t ci set-pipeline -p $(SERVICE) -c config/pipelines/review.yml -n
	@fly -t ci unpause-pipeline -p $(SERVICE)

deploy:
	@helm install --name $(SERVICE) config/charts/$(SERVICE) --set="image.tag=$(VERSION)"

upgrade:
	@helm upgrade $(SERVICE) config/charts/$(SERVICE) --set="image.tag=$(VERSION)"

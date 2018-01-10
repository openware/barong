# Kite Generate Service

```shell
kite generate service NAME --git=GIT --image=IMAGE
```

## Description

Creates __folder__, which contains:

- `VERSION`
- `docs/pipeline.md`
- `Dockerfile`
- `Makefile`
- `config/`

### VERSION
This file contains current __version__ of your project.

### docs/pipeline.md
Created basic __documentation__ with explanation of generated concourse pipeline.

### Dockerfile
Kite generates default `Dockerfile` with nginx.

*Example:*

```dockerfile
FROM nginx:1.13
# MAINTAINER Some Name <email@test.com>

RUN echo "Hello, Test!" > /usr/share/nginx/html/index.html
```

### Makefile
Kite generates `Makefile` for easy run, push, deploy, and manage kite generated pipeline.

*Example:*

```makefile
VERSION := $(shell cat VERSION)
IMAGE   := eu.gcr.io/test-production/test:$(VERSION)

.PHONY: default build push run ci deploy

default: build run

build:
  @echo '> Building "test" docker image...'
  @docker build -t $(IMAGE) .

push: build
  docker push $(IMAGE)

run:
  @echo '> Starting "test" container...'
  @docker run -d $(IMAGE)

ci:
  @fly -t ci set-pipeline -p test -c config/pipelines/review.yml -n
  @fly -t ci unpause-pipeline -p test

deploy:
  @helm install ./config/charts/test --set "image.tag=$(VERSION)"
```

### Config

Kite generates subfolder with stuff for helm chart and concourse pipeline.

You can __configure__ folder name with `--output NAME`.

By default it called `config/`. We recommend you to use name `.kite/`.

# Getting started with kite generate service

Lets start from basic command.

Kite have three __required__ parameters:

- `service name`
- `--image IMAGE`
- `--git LINK`

You can use `http` or `ssh` link to git repository.
You can use Docker Hub, GCP Container Registry, etc as path to your docker image.

*Example:*

```shell
kite generate service test --git ssh@github.com:example/test.git --image eu.gcr.io/test-project/test-image
```

Kite have __6 optional__ parameters:

- `--name=NAME` Name of the service
- `--output=OUTPUT` Config output sub-directory
- `--slack=SLACK` Slack notifications
- `--provider=PROVIDER` Cloud provider (AWS, GCP)
- `--image-version=IMAGE_VERSION` Docker image tag, defualt 0.1.0
- `--chart-version=CHART_VERSION` Chart version, default 0.1.0

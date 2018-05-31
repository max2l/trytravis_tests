include .env

all: docker_build docker_hub_login push_all_images

docker_build: build_comment build_post build_ui build_prometheus build_cloudprober build_alertmanager build_telegraf

build_comment:
		@echo $$USER_NAME
		cd src/comment/ && sh docker_build.sh

build_post:
		cd src/post-py/ && sh docker_build.sh

build_ui:
		cd src/ui/ && sh docker_build.sh

build_prometheus:
		cd monitoring/prometheus && docker build -t $(USER_NAME)/prometheus .

build_cloudprober:
		cd monitoring/cloudprober && docker build -t $(USER_NAME)/cloudprober:$(CLOUDPROBER_VER) .

build_alertmanager:
		cd monitoring/alertmanager && docker build -t $(USER_NAME)/alertmanager .

build_telegraf:
		cd monitoring/telegraf && docker build -t $(USER_NAME)/telegraf:$(TELEGRAF_VER) .

build_alertmanager:
		cd monitoring/alertmanager && docker build -t $(USER_NAME)/alertmanager:$(ALERTMANAGER_VER) .

docker_hub_login:
		echo $(DOCKER_HUB_PASSWORD)|docker login --username $(USER_NAME) --password-stdin

push_all_images:
		docker push $(USER_NAME)/ui && \
 		docker push $(USER_NAME)/comment && \
		docker push $(USER_NAME)/post && \
		docker push $(USER_NAME)/prometheus && \
		docker push $(USER_NAME)/cloudprober:$(CLOUDPROBER_VER) && \
		docker push $(USER_NAME)/alertmanager && \
		docker push $(USER_NAME)/telegraf:$(TELEGRAF_VER)


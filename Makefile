ACCOUNT_ID := $(shell eai account get --fields fullName --no-header)
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)
IMAGE_NAME := registry.console.elementai.com/${ACCOUNT_ID}/test2_shuriken:${TIMESTAMP}
USER_ID :=$(shell id -u ${USER})
TMP_CONFIG := tmp_config.yaml

# toolkit directories
CODE_DATA_NAME := ${ACCOUNT_ID}.test

build-image:
	@echo "Building image: ${IMAGE_NAME_AND_TAG}"
	@echo ${IMAGE_NAME} >LATEST_IMAGE_VERSION
	echo "export PYPI_ACCESS_KEY=${PYPI_ACCESS_KEY}" >> .dockerenv
	echo "export PYPI_SECRET_KEY=${PYPI_SECRET_KEY}" >> .dockerenv
	# Enable docker buildkit for passing secrets
	DOCKER_BUILDKIT=1 docker build -f Dockerfile \
	--secret id=env,src=.dockerenv \
	--tag $(IMAGE_NAME) \
	.
	rm .dockerenv

# rebuild is automatic
push-image: build-image
	docker push ${IMAGE_NAME}

# print-image-name:
# 	@echo ${IMAGE_NAME}

# Launch shuriken experiment
# CONFIG=config to run
# train-shuriken-skip-build:
# 	sed "s!{TIMESTAMP}!${TIMESTAMP}!g" $(CONFIG) > $(TMP_CONFIG)
# 	shuriken-launch $(TMP_CONFIG) -d $(EXPERIMENTS_DATA_NAME) --worker-image $(IMAGE_NAME) --run
# 	rm $(TMP_CONFIG)

# train-shuriken: push-image train-shuriken-skip-build

launch-interactive: push-image
	eai job new --env HOME=/home/toolkit\
		--restartable\
		--name seq2graph_$(TIMESTAMP)\
		--mem 32 --gpu 1 --cpu 4 --gpu-mem 32 --gpu-model-filter=!a100\
		--image $(IMAGE_NAME)\
		--data $(CODE_DATA_NAME):/code\
		--data $(EXPERIMENTS_DATA_NAME):/experiments \
		--data $(DATASETS_DATA_NAME):/data\
		--data snow.dorajam.home:/home/toolkit \
		-- /tk/bin/start.sh bash -c "while true; do sleep 3600; done"

ROOT = $(shell git rev-parse --show-toplevel)

TERRAFORM_IMAGE 	= 760097843905.dkr.ecr.eu-west-1.amazonaws.com/hashicorp/terraform:light
FLAKE8_IMAGE 		= 760097843905.dkr.ecr.eu-west-1.amazonaws.com/wellcome/flake8:latest
FORMAT_PYTHON_IMAGE = 760097843905.dkr.ecr.eu-west-1.amazonaws.com/wellcome/format_python:112

lint-python:
	$(ROOT)/docker_run.py -- \
		--volume $(ROOT):/data \
		--workdir /data \
		$(FLAKE8_IMAGE) \
		    --exclude .git,__pycache__,target,.terraform \
		    --ignore=E501,E122,E126,E203,W503

format-terraform:
	$(ROOT)/docker_run.py --aws -- \
		--volume $(ROOT):/repo \
		--workdir /repo \
		$(TERRAFORM_IMAGE) fmt -recursive

format-python:
	$(ROOT)/docker_run.py -- \
		--volume $(ROOT):/repo \
		$(FORMAT_PYTHON_IMAGE)

format: format-terraform format-python

lint: lint-python
	git diff --exit-code

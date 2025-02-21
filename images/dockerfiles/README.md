# Dockerfiles

This directory contains Dockerfiles used for building various Docker images required for the platform infrastructure.

## Dockerfiles

- [`awstoe`](./awstoe/): Used to build the AWSTOE image, used for local testing and development of AWS Image Builder components.
- [`flake8`](./flake8/): Used to build the flake8 image, used for [linting Python code in the Catalogue pipeline](https://github.com/wellcomecollection/catalogue-pipeline/blob/6f6e8426af58e5b617d08d4cf2c810bf61ebce3e/builds/run_linting.sh#L14).
- [`fluentbit`](./fluentbit/): Used to build the Fluentbit image, used for shipping logs to CloudWatch as a container sidecar.
- [`jvm_container_lambda`](./jvm_container_lambda/): Used to build the Java / Scala Lambda Container Image, used for running JVM code in AWS Lambda as a container based Lambda.
- [`nginx`](./nginx/): Used to build the Nginx image, used as a reverse proxy in our ECS services that require it. It's templated for various purposes, including:
  - [`nginx/apigw.nginx.conf`](./nginx/apigw.nginx.conf): Used for the API Gateway service including the storage service, adds CORS headers.
  - [`nginx/frontend.nginx.conf`](./nginx/frontend.nginx.conf): Used for wellcomecollection.org, performs gzip compression.
  - [`nginx/frontend_identity.nginx.conf`](./nginx/frontend_identity.nginx.conf): Used for the Identity service, performs gzip compression, redacts PII in logs.
- [`sbt_wrapper`](./sbt_wrapper/): Used to build the sbt wrapper image, used for running the [sbt test runner in the Catalogue pipeline](https://github.com/wellcomecollection/storage-service/blob/5f6a8590e3702bdebbe8c912b5d49c166f76e698/builds/run_sbt_task_in_docker.sh#L62).
- [`tox`](./tox/): Used to build the tox image, used for running the [tox test runner in the Catalogue pipeline](https://github.com/wellcomecollection/catalogue-pipeline/blob/6f6e8426af58e5b617d08d4cf2c810bf61ebce3e/builds/run_python_tests.sh#L16).

## Building the Images

To build the Docker images, a variety og build scripts are available in this directory:
- [`publish_image.sh`](./publish_image.sh): Used to build and publish most images to the ECR repository, for this to work it requires ECR repositories to have been provisioned using the Terraform in the `./terraform` directory.
- [`publish_nginx_images.sh`](./publish_nginx_images.sh): Used to build and publish the NGINX images to the ECR repository, it uses the `template.Dockerfile` to build the images with the correct configuration file, so it has a slightly different build process.

## Warning

**The images in this directory are used across the platform, so changes to them should be carefully considered and tested.**

For example, `fluentbit` & `nginx` are used as sidecars in the ECS services, so changes to them that overwrite existing tags could have a knock-on effects across the platform including user facing services.

Best practise is to always use pinned versions of the images in the ECS task definitions to avoid unexpected changes, and **never** overwrite existing tags in the ECR repository unless you are sure of the consequences.
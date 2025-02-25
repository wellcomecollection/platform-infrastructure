# images

This folder contains the configuration for some Docker images we use across the platform and our build system.

In particular, it contains:

*   [`dockerfiles`](./dockerfiles) – Dockerfiles for custom images that we've created
*   [`terraform`](./terraform) – ECR repositories in our own account that mirror images from Docker Hub, so we don't hit their [download rate limits][rate limits]

The infrastructure here is composed of:

- ECR repositories for the images we build here, in public / private pairs so these can be used in ECS services, and as part of our build process to control build environments.
- [AWS Image Builder](https://docs.aws.amazon.com/imagebuilder/latest/userguide/what-is-image-builder.html) pipelines to build EC2 images required where we use EC2 instances and need a way to build AMIs consistently. These to allow us to add Qualys & Crowdstrike agents to the base images for compliance reasons.

[rate limits]: https://docs.docker.com/docker-hub/download-rate-limit/

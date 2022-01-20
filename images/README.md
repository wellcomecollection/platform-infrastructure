# images

This folder contains the configuration for some Docker images we use across the platform and our build system.

In particular, it contains:

*   [`dockerfiles`](./dockerfiles) – Dockerfiles for custom images that we've created
*   [`terraform`](./terraform) – ECR repositories in our own account that mirror images from Docker Hub, so we don't hit their [download rate limits][rate limits]

[rate limits]: https://docs.docker.com/docker-hub/download-rate-limit/

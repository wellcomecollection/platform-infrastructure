# Nginx configurations

These are the nginx configurations used across the platform. 

By using `template.Dockerfile` and providing the config file name as the build argument `CONFIG_TEMPLATE`, you can build an image using that config file. Environment variables will be substituted in [as per the docs](https://github.com/docker-library/docs/tree/d7730a64774bdec6cd8cd75756ed60ea10d7b534/nginx#using-environment-variables-in-nginx-configuration-new-in-119).

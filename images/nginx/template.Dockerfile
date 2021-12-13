FROM nginx:1.21.4-alpine

# Set this so the given config overrides the root config
ENV NGINX_ENVSUBST_OUTPUT_DIR /etc/nginx

ARG CONFIG_TEMPLATE
COPY ${CONFIG_TEMPLATE} /etc/nginx/templates/nginx.conf.template

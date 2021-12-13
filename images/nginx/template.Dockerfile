FROM nginx:1.21.4-alpine

ARG CONFIG_TEMPLATE
COPY ${CONFIG_TEMPLATE} /etc/nginx/templates/nginx.conf.template

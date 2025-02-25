FROM public.ecr.aws/amazoncorretto/amazoncorretto:11

LABEL maintainer="Wellcome Collection <digital@wellcomecollection.org>"

RUN yum install awscli -y
COPY bash_secrets_extension.sh /opt/extensions/bash_secrets_extension.sh

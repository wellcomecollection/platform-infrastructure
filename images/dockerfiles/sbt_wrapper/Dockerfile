FROM public.ecr.aws/docker/library/eclipse-temurin:11-jre

LABEL maintainer = "Wellcome Collection <dev@wellcomecollection.org>"
LABEL description = "A Docker image for running SBT"

ARG SBT_VERSION=1.4.1

ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin

RUN apt-get update
RUN apt-get install -y rsync bash docker docker-compose

COPY install_sbt.sh /
RUN /install_sbt.sh

VOLUME /repo
WORKDIR /repo

COPY run_sbt.sh /

ENTRYPOINT ["/run_sbt.sh"]

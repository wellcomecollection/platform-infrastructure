FROM openjdk:11.0-jre-slim

LABEL maintainer = "Wellcome Collection <dev@wellcomecollection.org>"
LABEL description "A Docker image for running SBT"

ENV SBT_VERSION 1.4.1
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin

COPY install_docker_compose.sh /
RUN /install_docker_compose.sh

COPY install_sbt.sh /
RUN /install_sbt.sh

VOLUME /repo
WORKDIR /repo

COPY run_sbt.sh /
COPY populate_sbt_cache.py /

ENTRYPOINT ["/run_sbt.sh"]

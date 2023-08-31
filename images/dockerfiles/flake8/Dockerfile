FROM python:3-alpine

LABEL maintainer = "Wellcome Collection <dev@wellcomecollection.org>"

RUN pip install flake8

WORKDIR /src
VOLUME ["/src"]

ENTRYPOINT ["flake8"]

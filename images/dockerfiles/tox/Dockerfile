FROM python:3.6

LABEL maintainer = "Wellcome Collection <dev@wellcomecollection.org>"

RUN pip install tox

WORKDIR /src
VOLUME ["/src"]

ENTRYPOINT ["tox"]

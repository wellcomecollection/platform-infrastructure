FROM 760097843905.dkr.ecr.eu-west-1.amazonaws.com/node:12.18.3

RUN apt-get update && apt-get install -yq --no-install-recommends zip

WORKDIR /build
ADD . /build

RUN yarn && yarn build

CMD ["true"]

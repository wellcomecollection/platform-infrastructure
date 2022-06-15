FROM public.ecr.aws/docker/library/node:12-slim

RUN apt-get update && apt-get install -yq --no-install-recommends zip

WORKDIR /build
ADD . /build

RUN yarn && yarn build

CMD ["true"]

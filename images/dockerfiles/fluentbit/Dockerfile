FROM public.ecr.aws/aws-observability/aws-for-fluent-bit:2.29.1

LABEL maintainer "Wellcome Collection <wellcomedigitalplatform@wellcome.org>"
LABEL description "Sends logs from platform applications to Elasticsearch"

ADD extra.conf /extra.conf

ADD parsers.conf /parsers.conf

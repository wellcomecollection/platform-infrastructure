FROM amazonlinux:2

RUN yum install awscli -y
ADD https://awstoe-us-east-1.s3.us-east-1.amazonaws.com/latest/linux/arm64/awstoe /usr/local/bin/awstoe
RUN chmod +x /usr/local/bin/awstoe
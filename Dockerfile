FROM alpine:latest
MAINTAINER "Pim Snel pim@lingewoud.nl>"

ENV BASE_PACKAGES bash curl wget git less rsync zip openssh
ENV BUILD_PACKAGES curl-dev ruby-dev build-base libffi-dev
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler
ENV PYTHON_PACKAGES groff python py-pip

# Update and install all of the required packages.
# At the end, remove the apk cache
RUN apk update && \
    apk upgrade && \
    apk add $BASE_PACKAGES && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    apk add $PYTHON_PACKAGES && \
    rm -rf /var/cache/apk/*

# Install AWS Cli
RUN pip install --upgrade pip
RUN pip install awscli
RUN pip install awsebcli
ENV PAGER="less"

# AWS credentials dir
RUN mkdir ~/.aws
RUN mkdir ~/.ssh
RUN chmod 700 ~/.ssh

RUN mkdir /usr/app
WORKDIR /usr/app

COPY Gemfile /usr/app/
RUN bundle install

CMD ["aws"]

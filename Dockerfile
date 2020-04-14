FROM python:3-alpine
WORKDIR /

RUN apk add --no-cache \
  bash \
  curl \
  git \
  jq \
  openssh

RUN mkdir /root/.aws

COPY assume-role.sh /usr/local/bin/assume-role

## Install Pip Packages
RUN pip3 install --upgrade awscli

## Install Terraform
ENV TERRAFORM_VERSION=0.12.24

RUN curl -L -o ./terraform.zip \
    https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip -d /usr/local/bin ./terraform.zip && \
    rm terraform.zip

ENTRYPOINT bash
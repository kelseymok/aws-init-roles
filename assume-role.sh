#!/usr/bin/env bash

set -e

role=$1
if [ -z $role ]; then
  echo "Role not set."
  exit 1
fi

mfa_serial=$(aws configure get mfa_serial --profile base)
read -p "Enter MFA (${mfa_serial}): " mfa_response
if [ -z "${mfa_response}" ]; then
  echo "MFA not provided"
  exit 1
fi

account=$(aws sts get-caller-identity --profile base | jq -r '.Account')

response=$(aws sts assume-role \
--role-arn "arn:aws:iam::${account}:role/${role}" \
--role-session-name session \
--profile base \
--serial-number "${mfa_serial}" \
--token-code "${mfa_response}")

aws configure set aws_access_key_id $(echo $response | jq -r '.Credentials.AccessKeyId') --profile "${role}"
aws configure set aws_secret_access_key $(echo $response | jq -r '.Credentials.SecretAccessKey') --profile "${role}"
aws configure set aws_session_token $(echo $response | jq -r '.Credentials.SessionToken') --profile "${role}"


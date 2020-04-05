#!/usr/bin/env bash

set -e
set -o nounset
set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" ; pwd -P)
PROJECT_ROOT="${SCRIPT_DIR}/."

goal_build() {
  pushd "${SCRIPT_DIR}" > /dev/null
      docker build -t dev-env  .
  popd > /dev/null
}

goal_assume-role() {
  pushd "${SCRIPT_DIR}" > /dev/null
    role="${1:-}"
    if [ -z "${role}" ]; then
      echo "Role name not supplied"
      exit 1
    fi

    mounted_dir=$(cd ${PROJECT_ROOT}; pwd)
    home_dir=$(cd ~; pwd)
    echo "Mounting ${mounted_dir}"

    if [ ! -z "$(docker ps -a | grep dev-env)" ]; then
      docker rm -f dev-env
    fi


    docker run -it \
      --name dev-env \
      -v "${mounted_dir}:/app" \
      -v "${home_dir}/.aws:/root/.aws" \
      --entrypoint="" \
      dev-env assume-role $role
  popd > /dev/null
}

goal_run() {
  pushd "${SCRIPT_DIR}" > /dev/null
    mounted_dir=$(cd ${PROJECT_ROOT}; pwd)
    home_dir=$(cd ~; pwd)
    echo "Mounting ${mounted_dir}"

    if [ ! -z "$(docker ps -a | grep dev-env)" ]; then
      docker rm -f dev-env
    fi


    docker run -it \
      --name dev-env \
      -v "${mounted_dir}:/app" \
      -v "${home_dir}/.aws:/root/.aws" \
      dev-env
  popd > /dev/null
}

cleanup-containers() {
  container=$1
  if [ -z "${container}" ]; then
    echo "You provided an empty container. Usage <func> <container-name>"
    exit 1
  fi

  if [ ! -z "$(docker ps -a | grep $container)" ]; then
    docker rm -f $container
  fi
}

TARGET=${1:-}
if type -t "goal_${TARGET}" &>/dev/null; then
  "goal_${TARGET}" ${@:2}
else
  echo "Usage: $0 <goal>

goal:
    build                   - Builds container
    run                     - Runs container
    assume-role             - Assumes Role from argument and updates Shared Credentials with valid session
"
  exit 1
fi

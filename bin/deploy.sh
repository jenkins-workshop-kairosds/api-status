#!/usr/bin/env bash

TAG=$1
PORT=$2
ENVIRONMENT=$3

/usr/local/bin/redpanda-rancher create -p api-status-${ENVIRONMENT} -f docker-compose.yml

#!/bin/bash
echo "starting up confluent kafka..."
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
docker-compose -f $DIR/confluent-kafka.yml up -d
sleep 5
echo "Started."
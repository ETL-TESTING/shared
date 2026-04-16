#!/bin/bash
echo "shutting down confluent kafka..."
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker-compose -f $DIR/confluent-kafka.yml logs --no-color > kafka-server.log
docker-compose -f $DIR/confluent-kafka.yml kill
docker-compose -f $DIR/confluent-kafka.yml rm -f
echo "Container logs dumped. See inside the folder"

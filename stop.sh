#!/bin/sh
# ./stop.sh

docker stop -t 1 sgminer
docker rm sgminer

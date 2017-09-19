#!/bin/sh
# ./run.sh

export CREA_ADDRESS=CRgURSBHqM5FzQhy2iuGKPAHycTUwzr3Ei
docker run --name sgminer --rm gcamerli/sgminer -k keccakc -o stratum+tcp://miner.creativechain.net:9160 -u $CREA_ADDRESS -p x

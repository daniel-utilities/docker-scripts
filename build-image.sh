#!/usr/bin/env bash

if [[ $# != 1 ]]; then
    echo "USAGE: build-image IMAGE:TAG"
    exit
fi

#docker build --rm --no-cache --tag "$1" ./
docker build --tag $1 ./


#!/usr/bin/env bash

if [[ $# != 1 ]]; then
    echo "USAGE: bash-image IMAGE:TAG"
    exit
fi

docker run --rm -it --entrypoint bash $1


#!/usr/bin/env bash

if [[ $# == 1 ]]; then
    ARR=(${1//:/ })
    IMAGE=${ARR[0]}
    TAG=${ARR[1]}
else
    echo "USAGE: load-image IMAGE:TAG"
    exit
fi

# IF a complete tarfile exists, use that
if [[ -f "$IMAGE-$TAG.tar" ]]; then

    docker image load --input $IMAGE-$TAG.tar

# Otherwise check if the tar was split into parts, then concatenate them alphabetically and pipe to docker image load
elif test -n "$(find ./ -maxdepth 1 -name "$IMAGE-$TAG.tar.part-*" -print -quit)"; then

    cat $IMAGE-$TAG.tar.part-* | docker image load

else
    echo "Error: $IMAGE-$TAG.tar not found"
fi

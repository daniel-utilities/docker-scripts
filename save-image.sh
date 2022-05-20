#!/usr/bin/env bash

if [[ $# == 1 ]]; then
    ARR=(${1//:/ })
    IMAGE=${ARR[0]}
    TAG=${ARR[1]}
    SPLIT=0
elif [[ $# == 2 ]]; then
    ARR=(${1//:/ })
    IMAGE=${ARR[0]}
    TAG=${ARR[1]}
    SPLIT=$2
else
    echo "USAGE: save-image IMAGE:TAG [SPLIT]"
    exit
fi

docker image save -o $IMAGE-$TAG.tar $IMAGE:$TAG

if [[ $SPLIT != 0 ]]; then
    split -b $SPLIT $IMAGE-$TAG.tar $IMAGE-$TAG.tar.part-
fi



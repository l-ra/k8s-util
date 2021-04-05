#!/bin/bash
set -e -u -o pipefail

WHICH=$1 # MINOR PATCH
if [ $# -gt 1 ]; then
    IMAGE_TAG=$2
else
    IMAGE_TAG=__NOCHANGE__
fi

CURRENT_VER=$(cat Chart.yaml | grep ^version: | sed -e 's/^version:\s\+//')
CURRENT_PATCH=$(echo $CURRENT_VER | sed -e 's/^[0-9]\+\.[0-9]\+\.\([0-9]\+\)/\1/')
CURRENT_MINOR=$(echo $CURRENT_VER | sed -e 's/^[0-9]\+\.\([0-9]\+\)\.[0-9]\+/\1/')
CURRENT_MAJOR=$(echo $CURRENT_VER | sed -e 's/^\([0-9]\+\)\.[0-9]\+\.[0-9]\+/\1/')


case $WHICH in

    PATCH)
    NEW_MAJOR=$CURRENT_MAJOR
    NEW_MINOR=$CURRENT_MINOR
    NEW_PATCH=$(($CURRENT_PATCH + 1))
    ;;

    MINOR)
    NEW_MAJOR=$CURRENT_MAJOR
    NEW_MINOR=$CURRENT_MINOR
    NEW_PATCH=$(($CURRENT_PATCH + 1))
    ;;

    *)
    echo bad which only MINOR and PATCH is allowed

esac

#printf "OLD: %s.%s.%s\n" $CURRENT_MAJOR $CURRENT_MINOR $CURRENT_PATCH 
#printf "NEW: %s.%s.%s\n" $NEW_MAJOR $NEW_MINOR $NEW_PATCH 
NEW_VER=$(printf "%s.%s.%s" $NEW_MAJOR $NEW_MINOR $NEW_PATCH)
sed -i  -e "s/^version: .*$/version: $NEW_VER/" Chart.yaml

if [ "$IMAGE_TAG" != "__NOCHANGE__" ]; then
    sed -i -e "s/  tag:.*/  tag: $IMAGE_TAG/" values.yaml
fi

echo "updated version to $NEW_VER, new image tag: $IMAGE_TAG" 


#!/bin/bash
set -e -u -o pipefail

# clean
rm -f *.tgz index*.yaml

mkdir /repo

# package 
helm package . -d /repo
PKG_NAME=$(basename $(ls /repo/*.tgz))

# download old yaml
curl --insecure -u $HELM_REPO_USER:$HELM_REPO_PWD -XGET $HELM_REPO_URL/index.yaml -o /repo/index-old.yaml

helm repo index /repo --merge /repo/index-old.yaml 
echo PKG_NAME=$PKG_NAME
curl --insecure -H 'Content-type: application/octet-stream' \
     -u $HELM_REPO_USER:$HELM_REPO_PWD --data-binary @/repo/$PKG_NAME  \
     -XPUT $HELM_REPO_URL/$PKG_NAME 
curl --insecure -H 'Content-type: text/x-yaml' \
     -u $HELM_REPO_USER:$HELM_REPO_PWD --data-binary @/repo/index.yaml\
     -XPUT  $HELM_REPO_URL/index.yaml 
rm -f *.tgz index*.yaml



#!/bin/bash
set -e -u -o pipefail

# clean
rm -f *.tgz index*.yaml

# package 
helm package .
PKG_NAME=$(basename $(ls *.tgz))

# download old yaml
curl --insecure -u $HELM_REPO_USER:$HELM_REPO_PWD -XGET $HELM_REPO_URL/index.yaml -o index-old.yaml

helm repo index . --merge index-old.yaml 
echo PKG_NAME=$PKG_NAME
curl --insecure -H 'Content-type: application/octet-stream' \
     -u $HELM_REPO_USER:$HELM_REPO_PWD --data-binary @$PKG_NAME  \
     -XPUT $HELM_REPO_URL/$PKG_NAME 
curl --insecure -H 'Content-type: text/x-yaml' \
     -u $HELM_REPO_USER:$HELM_REPO_PWD --data-binary @index.yaml\
     -XPUT  $HELM_REPO_URL/index.yaml 
rm -f *.tgz index*.yaml



#!/usr/bin/env bash

## verify environment file input 

DIR="$( cd "$( dirname "$0" )" && pwd )"
source ${DIR}/env.sh

if [ $# -lt 2 ]; then
    echo "${RED_TEXT}Argument mof ENV file and CloudPak must be specified${RESET_TEXT}"
    exit 90
fi

ENVIRONMENT_FILE=$1
CLOUD_PAK=$2

if [ ! -f ${DIR}/../env/${ENVIRONMENT_FILE}-env.sh ]; then
   echo "${RED_TEXT}${ENVIRONMENT_FILE} does NOT exists in ${DIR}/env !${RESET_TEXT}"
   exit 99
fi

## verify cluster connectivity and size



## get daffy code 
DAFFY_URL=http://get.daffy-installer.com
DAFFY_CONTEXT=download-scripts
DAFFY_INSTALL_TAR=daffy.tar
pushd ..
wget ${DAFFY_URL}/${DAFFY_CONTEXT}/${DAFFY_INSTALL_TAR}
tar -xvf ${DAFFY_INSTALL_TAR} &> /dev/null
rm -fR  ${DAFFY_INSTALL_TAR} &> /dev/null

  if [ ! -f ${DIR}/../${CLOUD_PAK}/build.sh ]; then
     echo "${RED_TEXT}Component name ${CLOUD_PAK} does NOT exists.${RESET_TEXT}"
     exit 88
  fi

## Build repository 

#### Install argocd
#### set git source

#### implement global pull secret 
#### prepare template files

#### namespaces
#### serviceaccounts
#### roles and sccs
#### operators
#### instances
#### services

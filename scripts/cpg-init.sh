#!/usr/bin/env bash
# This script initialize the gitops repository for CloudPak GitOps from Daffy 
# must be run before activating the GitOps resources
# set -x
## Check GIT_ORG and current git path
DIR="$( cd "$( dirname "$0" )" && cd .. && pwd )"
source ${DIR}/scripts/env.sh

git -C ${DIR} rev-parse 2>/dev/null
if [ "$?" -eq 0 ]; then
    echo "${ICON_SUCCESS}Target directory belongs to a GIT repository."
else
    echo "${ICON_FAIL}${RED_TEXT}Script is not in a git repo${RESET_TEXT}"
    exit
fi

GIT_URL=$(git config --get remote.origin.url)
if [[ ${GIT_URL} = git* ]]; then 
    repo=$(echo ${GIT_URL} | cut -d":" -f2)
    GIT_ORG=$(echo ${repo} | cut -d"/" -f1)
    GIT_REPO=$(echo ${repo} | cut -d"/" -f2)
else
    GIT_ORG=$(echo ${GIT_URL} | cut -d"/" -f4)
    GIT_REPO=$(echo ${GIT_URL} | cut -d"/" -f5)
fi

# Check GIT_TOKEN and GIT_ORG

## get daffy code 
DAFFY_URL=http://get.daffy-installer.com
DAFFY_CONTEXT=download-scripts
DAFFY_INSTALL_TAR=daffy.tar
wget ${DAFFY_URL}/${DAFFY_CONTEXT}/${DAFFY_INSTALL_TAR}
tar -xvf ${DAFFY_INSTALL_TAR} &> /dev/null
rm -fR  ${DAFFY_INSTALL_TAR} &> /dev/null
echo "${ICON_SUCCESS}Daffy executable downloaded."

## load daffy base functions and env
source ${DIR}/daffy/env.sh
source ${DIR}/daffy/functions.sh "skip" > /dev/null
echo "${ICON_SUCCESS}Daffy environment established ${DAFFY_VERSION}."

## Build repository 
echo ${DAFFY_VERSION} > ${DIR}/.daffy_version
rm -rf ${DIR}/"@OSDIR@"

## for each of the CloudPak dir, iteratively build repo



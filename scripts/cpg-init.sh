#!/usr/bin/env bash
# This script initialize the gitops repository for CloudPak GitOps from Daffy 
# must be run before activating the GitOps resources
# set -x
SOURCE_REPO=${SOURCE_REPO:-copagod}
SOURCE_ORG=${SOURCE_ORG:-vbudi000}
if [[ -z "${OUTPUT_DIR}" ]]; then
    OUTPUT_DIR=$(pwd)
fi
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
source ${SCRIPT_DIR}/env.sh

git -C ${OUTPUT_DIR} rev-parse 2>/dev/null
if [ "$?" -eq 0 ]; then
    echo "${ICON_FAIL}${RED_TEXT}${OUTPUT_DIR} is owned by a git repo${RESET_TEXT}"
    exit
fi
## Check GIT_ORG and current git path

if [[ -z "${GIT_ORG}" ]]; then
    echo "${ICON_FAIL}${RED_TEXT}GIT_ORG \"${GIT_ORG}\" is undefined${RESET_TEXT}"
    exit
fi
if [[ -z "${GIT_TOKEN}" ]]; then
    echo "${ICON_FAIL}${RED_TEXT}GIT_TOKEN \"${GIT_TOKEN}\" is undefined${RESET_TEXT}"
    exit
fi

## login to git and check repo
echo $GIT_TOKEN | gh auth login --with-token
if [ "$?" -ne 0 ]; then
    echo "${ICON_FAIL}${RED_TEXT}Token invalid, cannot login to GitHub ${RESET_TEXT}"
    exit
fi
gh repo view ${GIT_ORG}/${SOURCE_REPO} >/dev/null 2>&1
if [ "$?" -eq 0 ]; then
    echo "${ICON_FAIL}${RED_TEXT}GitHub Repository ${GIT_ORG}/${SOURCE_REPO} already exist${RESET_TEXT}"
    exit
fi

dirc=$(ls ${SOURCE_REPO} >/dev/null 2>&1| wc -l)
if [ "$dirc" -gt 0 ]; then
    echo "${ICON_FAIL}${RED_TEXT}${SOURCE_REPO} already exist in ${OUTPUT_DIR}${RESET_TEXT}"
    exit
fi

### begin processing 
echo "${ICON_SUCCESS}All initial check completed."

gh repo fork https://github.com/${SOURCE_ORG}/${SOURCE_REPO} --org ${GIT_ORG} --clone  
CDIR=${OUTPUT_DIR}/${SOURCE_REPO}
GIT_REPO=${SOURCE_REPO}
echo "${ICON_SUCCESS}Repository is forked to ${GIT_ORG}/${GIT_REPO} and cloned."
pushd ${CDIR}
## get daffy code 
DAFFY_URL=http://get.daffy-installer.com
DAFFY_CONTEXT=download-scripts
DAFFY_INSTALL_TAR=daffy.tar
wget ${DAFFY_URL}/${DAFFY_CONTEXT}/${DAFFY_INSTALL_TAR} >/dev/null 2>&1
tar -xvf ${DAFFY_INSTALL_TAR} &> /dev/null
rm -fR  ${DAFFY_INSTALL_TAR} &> /dev/null
echo "${ICON_SUCCESS}Daffy executable downloaded."

## load daffy base functions and env
source ${CDIR}/daffy/env.sh
source ${CDIR}/daffy/functions.sh "skip" > /dev/null
echo "${ICON_SUCCESS}Daffy environment established ==${DAFFY_VERSION}==."

## Build repository 
echo ${DAFFY_VERSION} > ${CDIR}/.daffy_version
rm -rf ${CDIR}/"@OSDIR@"

## for each of the CloudPak dir, iteratively build repo
PROJECT_NAME=${SOURCE_REPO}
PRODUCT_SHORT_NAME=${CLOUD_PAK}
BLOCK_SC="ocs-storagecluster-ceph-rbd"
FILE_SC="ocs-storagecluster-cephfs"
IBM_CLOUD_CATALOG_SOURCE="opencloud-operators"
## cp4ba
CP4BA_VERSION="22.0.1"
## cp4d
CP4D_STORAGE_CLASS=${FILE_SC}
CP4D_BLOCK_CLASS=${BLOCK_SC}
CP4D_VERSION="4.5.3"
## cp4i
CP4I_NAMESPACE="cp4i"
CP4I_VERSION="2022.2.1"
CP4I_STORAGE_CLASS=${FILE_SC}
CP4I_BLOCK_CLASS=${BLOCK_SC}
## cp4security
CP4SEC_VERSION="1.10"
CP4SEC_STORAGE_CLASS=${FILE_SC}
CP4SEC_BLOCK_CLASS=${BLOCK_SC}
## cp4waiops
CP4WAIOPS_VERSION="3.5.0"
CP4WAIOPS_STORAGE_CLASS=${FILE_SC}
CP4WAIOPS_BLOCK_STORAGE_CLASS=${BLOCK_SC}
CP4WAIOPS_SUBSCRIPTION_CHANNEL="v3.5"
## turbo
TURBO_PLATFORM_VERSION="8.5.7"
TURBO_BLOCK_STORAGE_CLASS=${BLOCK_SC}
## wsa
CPWSA_VERSION="1.4"
CP4WSA_SUBSCRIPTION_CHANNEL="v1.4"
AUTOBASE_VERSION="2.0.5"
AUTOMATIONUI_VERSION="1.3.5"
CPLIST="cp4ba cp4d cp4i cp4security cp4waiops turbo wsa"
#CPLIST="cp4d cp4i"
for CLOUD_PAK in ${CPLIST}; do
    echo "Processing ${CLOUD_PAK} directory"
    source ${CDIR}/daffy/${CLOUD_PAK}/env.sh
    source ${CDIR}/daffy/${CLOUD_PAK}/functions.sh
    pushd ${CDIR}/daffy/${CLOUD_PAK}

    TEMP_DIR=${CDIR}/gitops/2-software/${CLOUD_PAK}
    DIR=${CDIR}/daffy/${CLOUD_PAK}
    case ${CLOUD_PAK} in
        cp4ba)
            prepareCP4BAInputFiles
            ;;
        cp4d)
            prepareCP4DInputFiles
            ;;
        cp4i)
            prepareCP4IInputFiles
            ;;
        cp4security)
            prepareCP4SECInputFiles
            ;;
        cp4waiops)
            prepareCP4WAIOPSInputFiles
            ;;
        turbo)
            prepareTurboPlatformInputFiles
            ;;
        wsa)
            prepareWSAInputFiles
            ;;
        *)
            echo "Unknown CloudPak $CLOUD_PAK"
            ;;
    esac
    # create main kustomization for services
    pushd ${TEMP_DIR}
    cat <<EOF > kustomization.yaml
resources:
EOF
    find . -name *.yaml | sed 's|^./|#- |g' >> kustomization.yaml

    popd
    popd
    unset -f $(cat daffy/${CLOUD_PAK}/env.sh | grep "=" | grep -v '^#' | cut -d"=" -f1)
    unset -f $(cat daffy/${CLOUD_PAK}/functions.sh | grep "()" | grep -v '^#' | cut -d"(" -f1)
    ## list all loaded functions: declare -F | cut -c 12- 
    echo "${ICON_SUCCESS}Processed ${CLOUD_PAK} directory"
done

## Cleanup
rm -rf ${CDIR}/daffy
cd ${CDIR}
git add .
git commit -m "Initialized with Daffy v${DAFFY_VERSION}"
git push origin master
echo "${ICON_SUCCESS}${GREEN_TEXT}Ready for GitOps${RESET_TEXT}"
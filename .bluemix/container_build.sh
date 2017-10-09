#!/bin/bash
# The following colors have been defined to help with presentation of logs: green, red, label_color, no_color.
echo -e "${label_color}Starting build script${no_color}"

# The IBM Container Service CLI (ice), Git client (git), IDS Inventory CLI (ids-inv) and Python 2.7.3 (python) have been installed.
# Based on the organization and space selected in the Job credentials are in place for both IBM Container Service and IBM Bluemix
#####################
# Run unit tests    #
#####################
echo -e "${label_color}No unit tests cases have been checked in ${no_color}"

######################################
# Build Container via Dockerfile     #
######################################

# REGISTRY_URL=${CCS_REGISTRY_HOST}/${NAMESPACE}
# FULL_REPOSITORY_NAME=${REGISTRY_URL}/${IMAGE_NAME}:${APPLICATION_VERSION}

# Possible adding retries to build the image
if [ -f Dockerfile ]; then
    echo -e "${label_color}BUILDING ${FULL_REPOSITORY_NAME} ${no_color}"
    ${EXT_DIR}/utilities/sendMessage.sh -l info -m "New container build requested for ${FULL_REPOSITORY_NAME}"
    # build image
    BUILD_COMMAND=""
    if [ "${USE_CACHED_LAYERS}" == "true" ]; then
        BUILD_COMMAND="build --pull --tag ${FULL_REPOSITORY_NAME} ${WORKSPACE}"
        ice_retry ${BUILD_COMMAND}
        RESULT=$?
    else
        BUILD_COMMAND="build --no-cache --tag ${FULL_REPOSITORY_NAME} ${WORKSPACE}"
        ice_retry ${BUILD_COMMAND}
        RESULT=$?
    fi

    if [ $RESULT -ne 0 ]; then
        echo -e "${red}Error building image ${no_color}" | tee -a "$ERROR_LOG_FILE"
        echo "Build command: ice ${BUILD_COMMAND}"
        ice info
        ice images
        ${EXT_DIR}/print_help.sh
        ${EXT_DIR}/utilities/sendMessage.sh -l bad -m "Container build of ${FULL_REPOSITORY_NAME} failed"
        exit 1
    else
        ${EXT_DIR}/utilities/sendMessage.sh -l good -m "Container build of ${FULL_REPOSITORY_NAME} was successful"
        echo -e "${green}Container build of ${FULL_REPOSITORY_NAME} was successful ${no_color}"
    fi
else
    echo -e "${red}Dockerfile not found at the repository root${no_color}"
    exit 1
fi

######################################################################################
# Copy any artifacts that will be needed for deployment and testing to $WORKSPACE    #
######################################################################################
# copy deploy script
echo "Copying kube_deploy.sh script to WORKSPACE"
cp  $ARCHIVE_DIR/

# IMAGE_NAME from build.properties is used by Vulnerability Advisor job to reference the image qualified location in registry
echo "IMAGE_NAME=${FULL_REPOSITORY_NAME}" >> $ARCHIVE_DIR/build.properties
# RELEASE_NAME from build.properties is used in Helm Chart deployment to set the release name
echo "RELEASE_NAME=${IMAGE_NAME}" >> $ARCHIVE_DIR/build.properties

CHART_PATH=./chart/IBMGENERATED
if [ -f ${CHART_PATH}/values.yaml ]; then
    #Update Helm chart values.yml with image name and tag
    echo "UPDATING CHART VALUES:"
    sed -i "s~^\([[:blank:]]*\)repository:.*$~\1repository: ${REGISTRY_URL}/${IMAGE_NAME}~" ${CHART_PATH}/values.yaml
    sed -i "s~^\([[:blank:]]*\)tag:.*$~\1tag: ${APPLICATION_VERSION}~" ${CHART_PATH}/values.yaml
    cat ${CHART_PATH}/values.yaml
    cp -r ./chart/ $ARCHIVE_DIR/
else
    echo -e "${red}Helm chart values for Kubernetes deployment (/${CHART_PATH}/values.yaml) not found.${no_color}"
    exit 1
fi
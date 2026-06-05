#!/bin/bash

PIPELINE_DIR=${INTEGRATED_PIPELINE_DIR:-$(dirname `readlink -f $0`)}
WORK_DIR=${WORK_DIR:-"${PIPELINE_DIR}"}
CONFIG_FILE=${CONFIG_FILE:-"${PIPELINE_DIR}/configuration_integrated.txt"}

cd "${WORK_DIR}"

get_config(){
    grep -w "^$1" "${CONFIG_FILE}" | cut -d "=" -f 2
}

#!/bin/bash
# Shared helpers for integrated pipeline scripts.

SCRIPT_DIR=$(dirname `readlink -f ${BASH_SOURCE[0]}`)
PROJECT_DIR=$(dirname "${SCRIPT_DIR}")

DEFAULT_CONFIG_FILE="${PROJECT_DIR}/config/configuration_integrated.txt"
if [ -z "${CONFIG_FILE:-}" ] || [ ! -f "${CONFIG_FILE}" ]; then
    CONFIG_FILE="${DEFAULT_CONFIG_FILE}"
fi

if [ -z "${WORK_DIR:-}" ]; then
    WORK_DIR="${SCRIPT_DIR}"
fi

export SCRIPT_DIR
export PROJECT_DIR
export CONFIG_FILE
export WORK_DIR

cd "${WORK_DIR}"

get_config(){
    grep -w "^$1" "${CONFIG_FILE}" | cut -d "=" -f 2
}

#!/usr/bin/env bash

# Installation

export PROJECT_DIR="$2"
export VAGRANT_DIR="${PROJECT_DIR}/vagrant"
export VAGRANT_HOME_DIR="/home/vagrant"

source "${VAGRANT_HOME_DIR}/.bash/bash_profile/localAndVmShellScripts/_localAndVmConstants.sh"

export CONFIGURATION_FILE="${VAGRANT_DIR}/Configuration.yaml"
export CONFIGURATION_UTILITY="${VAGRANT_DIR}/php/configurationUtility.php"

# Usage of bash

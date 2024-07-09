#!/usr/bin/env bash

export scriptPath="$( dirname "${BASH_SOURCE[0]}" )"

function localShellScript(){

    source "${scriptPath}/.bash/bash_profile/localShellScripts/_localConstants.sh"

    source "${LOCAL_SCRIPTS}/systemOperations.sh"
    source "${LOCAL_SCRIPTS}/goto-local.sh"
    source "${LOCAL_SCRIPTS}/scripting-local.sh"

    return
}

# function vmShellScripts(){
#
#
#
#     source "${scriptPath}/.bash/bash_profile/vmShellScripts/_vmConstants.sh"
#
#     source "${scriptPath}/.bash/bash_profile/vmShellScripts/goto-vm.sh"
#
#
#     return
# }

function localAndVmShellScripts(){

    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/utils.sh"
    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/bash_logout.sh"
    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/bashrc.sh"
    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/enviromentConfiguration.sh"
    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/terminal.sh"
    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/fileAndFolder.sh"
    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/searching.sh"
    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/processManagement.sh"
    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/networking.sh"
    source "${scriptPath}/scripts/enviroment/localAndVmShellScripts/webDevelopment.sh"

#    source "${BASH_IT}/bash_it.sh"

    return
}

case $OSTYPE in
  darwin*)
    localShellScript
    localAndVmShellScripts
    ;;
  *)
#     vmShellScripts
    localAndVmShellScripts
    ;;
esac

#!/usr/bin/env bash

export scriptPath="$( dirname "${BASH_SOURCE[0]}" )"

function localShellScript(){

    source "${scriptPath}/.bash/bash_profile/localShellScripts/_localConstants.sh"

    source "${LOCAL_SCRIPTS}/systemOperations.sh"
    source "${LOCAL_SCRIPTS}/goto-local.sh"
    source "${LOCAL_SCRIPTS}/scripting-local.sh"

    return
}

function vmShellScripts(){



    source "${scriptPath}/.bash/bash_profile/vmShellScripts/_vmConstants.sh"

    source "${scriptPath}/.bash/bash_profile/vmShellScripts/goto-vm.sh"


    return
}

function localAndVmShellScripts(){

    source "${LOCAL_AND_VM_SCRIPTS}/utils.sh"
    source "${LOCAL_AND_VM_SCRIPTS}/bash_logout.sh"
    source "${LOCAL_AND_VM_SCRIPTS}/bashrc.sh"
    source "${LOCAL_AND_VM_SCRIPTS}/enviromentConfiguration.sh"
    source "${LOCAL_AND_VM_SCRIPTS}/terminal.sh"
    source "${LOCAL_AND_VM_SCRIPTS}/fileAndFolder.sh"
    source "${LOCAL_AND_VM_SCRIPTS}/searching.sh"
    source "${LOCAL_AND_VM_SCRIPTS}/processManagement.sh"
    source "${LOCAL_AND_VM_SCRIPTS}/networking.sh"
    source "${LOCAL_AND_VM_SCRIPTS}/webDevelopment.sh"

#    source "${BASH_IT}/bash_it.sh"

    return
}

case $OSTYPE in
  darwin*)
    localShellScript
    localAndVmShellScripts
    ;;
  *)
    vmShellScripts
    localAndVmShellScripts
    ;;
esac

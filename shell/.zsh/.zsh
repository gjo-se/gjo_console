#!/usr/bin/env zsh

SCRIPTPATH=$(dirname "$0")
echo ${SCRIPTPATH} SCRIPTPATH

function localShellScript(){

    source "${SCRIPTPATH}/.zsh_scripts/enviroment/localShellScripts/_localConstants.sh"

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

# TODO: aufräumen
export PATH=/Applications/PhpStorm.app/Contents/bin:$PATH
alias start-selenium-server="java -jar /usr/local/bin/selenium-server-standalone-3.9.1.jar"
export LDFLAGS="-L/usr/local/opt/bison/lib"
export PATH="/usr/local/opt/bison/bin:$PATH"

function composer() { COMPOSER="$(which composer)" || { echo "Could not find composer in path" >&2 ; return 1 ; } && sudo php5dismod -s cli xdebug ; $COMPOSER "$@" ; STATUS=$? ; sudo php5enmod -s cli xdebug ; return $STATUS ; }

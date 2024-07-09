#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi

./scripts/helper/echoHeader.sh 'Deploy content to LIVE'
source scripts/helper/cecho.sh

config_force=0
while test $# -gt 0; do
        case "$1" in
                -f|--force)
                        config_force=1
                        shift
                        ;;
                *)
                        shift
                        ;;
        esac
done

if [ "$config_force" != "1" ]; then
    echo "Generating security code, please wait..."
    code=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-6} | head -n 1`
    cecho "[  OK  ]" $green
    echo ""

    echo "To make sure you know what you're doing please enter the following code: $code"
    read input
    echo ""

    if [ "$code" != "$input" ]; then
        cecho "[ FAIL ] Code check failed." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
fi

if [ "$config_force" != "1" ]; then
    echo "Start deployment now? [y|n]:"
    read start
    echo ""

    if [ $start != 'y' ] && [ $start != 'Y' ]; then
        cecho "[ FAIL ] Deployment aborted" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
fi

redis-cli flushall

cd web > /dev/null
# this script has to run as sudo
sudo php typo3/cli_dispatch.phpsh kaercher_deployment -a deploy
cd - > /dev/null

./scripts/helper/echoFooter.sh 'Done.'
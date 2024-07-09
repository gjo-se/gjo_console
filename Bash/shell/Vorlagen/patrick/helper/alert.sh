#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit
fi;

function sendAlert()
{
    usage="USAGE: source scripts/helper/sendAlert.sh subject message"

    if [ -z "$1" ]; then
        echo "Please specify a subject."
        echo $usage
        exit
    fi;

    if [ -z "$2" ]; then
        echo "Please specify a message."
        echo $usage
        exit
    fi;

    cd web > /dev/null
    sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_central_control -a sendalert -j "$1" -m "$2"
    cd - > /dev/null
}
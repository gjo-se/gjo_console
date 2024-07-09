#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit
fi;

if [ -z $1 ]; then
    echo "Please specify a key."
    echo "USAGE: source scripts/helper/getConfig.sh KEY [SYSTEM]"
    exit
fi;

echo `php scripts/helper/php/getConfig.php $1 $2`
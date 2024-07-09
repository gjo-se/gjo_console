#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

source scripts/helper/cecho.sh

./scripts/helper/echoHeader.sh 'Import salesdata'

cmd="php typo3/cli_dispatch.phpsh kaercher_products -a importsalesdata"
cd web > /dev/null
sudo -u "www-data" -g "www-data" $cmd
cd - > /dev/null

./scripts/helper/echoFooter.sh 'Done.'
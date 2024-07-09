#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

./scripts/helper/echoHeader.sh 'Create storage index'
source scripts/helper/cecho.sh

cmd="php typo3/cli_dispatch.phpsh kaercher_central_control -a createstorageindex"
echo "Command: $cmd"
cd web > /dev/null
sudo -E -u www-data -g www-data $cmd
cd - > /dev/null
cecho "[  OK  ]" $green

./scripts/helper/echoFooter.sh 'Done.'
#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

./scripts/helper/echoHeader.sh 'Dos2Unix on scripts folder'

sudo find scripts/ -type f -name "*.sh" -exec dos2unix {} \;
sudo find scripts/ -type f -name "*.sh" -exec chmod +x {} \;

./scripts/helper/echoFooter.sh 'Done.'
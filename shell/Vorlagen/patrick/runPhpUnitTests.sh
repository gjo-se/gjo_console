#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

./scripts/helper/echoHeader.sh "Unitttests"

db_database=`./scripts/helper/getConfig.sh DB.database`
db_username=`./scripts/helper/getConfig.sh DB.username`
db_password=`./scripts/helper/getConfig.sh DBpassword`
db_host=`./scripts/helper/getConfig.sh DB.host`

export UnitTest=1

cd web;

folders=`find typo3conf/ext/ -maxdepth 1 -name "kaercher_*" -type d`;
for folder in $folders;
do
    unitTestFolder="$folder/Tests/Unit"
    if [ -d "$unitTestFolder" ]; then
        sudo -u www-data -g www-data php typo3/cli_dispatch.phpsh phpunit --colors --verbose --debug $unitTestFolder
    fi;
done
cd - > /dev/null

./scripts/helper/echoFooter.sh 'Done.'
#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi

./scripts/helper/echoHeader.sh 'Cleanup the sys_log table'
source scripts/helper/cecho.sh

db_database=`./scripts/helper/getConfig.sh DB.database`
db_username=`./scripts/helper/getConfig.sh DB.username`
db_password=`./scripts/helper/getConfig.sh DB.password`
db_host=`./scripts/helper/getConfig.sh DB.host`

threshold=`date --date "-1 month" +%s`

echo "Checking mysql installation..."
mysqlinstalled=`command -v mysql`
if [ -z "$mysqlinstalled" ]; then
    cecho "[ FAIL ] mysql is not installed." $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

echo "Cleaning up sys_log table..."
mysql -u"$db_username" -p"$db_password" -h"$db_host" $db_database -e "DELETE FROM sys_log WHERE tstamp < $threshold;"
cecho "[  OK  ]" $green
echo ""

./scripts/helper/echoFooter.sh 'Done.'
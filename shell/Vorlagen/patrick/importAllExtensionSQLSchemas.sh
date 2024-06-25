#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

./scripts/helper/echoHeader.sh 'Import all ext_tables.sql files' 'Delete the database tables you want to replace first'


db_database=`./scripts/helper/getConfig.sh DB.database`
db_username=`./scripts/helper/getConfig.sh DB.username`
db_password=`./scripts/helper/getConfig.sh DB.password`
db_host=`./scripts/helper/getConfig.sh DB.host`

find web/typo3conf/ext/ -name "ext_tables.sql" | awk '{ print "source",$0 }' | mysql --batch --force -u"$db_username" -p"$db_password" -h $db_host $db_database

./scripts/helper/echoFooter.sh 'Done.'

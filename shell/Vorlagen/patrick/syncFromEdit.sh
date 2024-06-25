#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

function switchBack()
{
    echo "Switching back to origin folder..."
    cd - > /dev/null
    cecho "[  OK  ]" $green
    echo ""
}

source scripts/helper/cecho.sh
source scripts/helper/alert.sh

./scripts/helper/echoHeader.sh 'Sync from Edit'

db_database=`./scripts/helper/getConfig.sh DB.database`
db_username=`./scripts/helper/getConfig.sh DB.username`
db_password=`./scripts/helper/getConfig.sh DB.password`
db_host=`./scripts/helper/getConfig.sh DB.host`

db_databasestage=`./scripts/helper/getConfig.sh DB.database EDIT`
db_usernamestage=`./scripts/helper/getConfig.sh DB.username EDIT`
db_passwordstage=`./scripts/helper/getConfig.sh DB.password EDIT`
db_hoststage=`./scripts/helper/getConfig.sh DB.host EDIT`

ignorabletables=();
ignorabletables[0]="sys_log"
ignorabletables[1]="sys_history"

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

ignorearg=""
for ignorabletable in ${ignorabletables[*]}
do
    ignorearg+=" --ignore-table=$db_databasestage.$ignorabletable"
done

echo "Checking mysql installation..."
mysqlinstalled=`command -v mysql`
if [ -z "$mysqlinstalled" ]; then
    cecho "[ FAIL ] mysql is not installed." $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

echo "Checking pv installation..."
pvinstalled=`command -v pv`
if [ -z "$pvinstalled" ]; then
    cecho "[ FAIL ] pv is not installed." $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

cecho "= SOURCE =" $magenta
echo "Mysql-Host: $db_hoststage"
echo "Database: $db_databasestage"
echo "Ignore-Arg: $ignorearg"
echo ""

cecho "= TARGET =" $magenta
echo "Mysql-Host: $db_host"
echo "Database: $db_database"
echo ""

if [ "$config_force" != "1" ]; then
    echo "Start database transfer now? [y|n]:"
    read start
    echo ""

    if [ $start != 'y' ] && [ $start != 'Y' ]; then
        cecho "[ FAIL ] Sync aborted" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
fi

temp="/tmp/deployment_`date +%s`"
echo "Creating temp folder $temp..."
sudo mkdir -p $temp
sudo chmod 0777 $temp
cecho "[  OK  ]" $green
echo ""

echo "Switching to $temp..."
cd $temp > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Creating schema dump from $db_databasestage..."
mysqldump -u$db_usernamestage -p$db_passwordstage -h$db_hoststage $db_databasestage -d --lock-tables=false > schema_dump.sql
cecho "[  OK  ]" $green
echo ""

echo "Creating data dump from $db_databasestage..."
mysqldump -u$db_usernamestage -p$db_passwordstage -h$db_hoststage $db_databasestage $ignorearg --lock-tables=false --no-create-info > content_dump.sql
cecho "[  OK  ]" $green
echo ""

echo "Checking data dump from $db_databasestage..."
grep -e "-- Dump completed" content_dump.sql > /dev/null
if [ $? -ne 0 ]; then
    switchBack
    sendAlert "Sync from EDIT failed" "Export failed."

    cecho "[ FAIL ] Export failed" $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

echo "Importing schema to $db_database..."
pv schema_dump.sql | mysql -h$db_host -u$db_username -p$db_password $db_database
cecho "[  OK  ]" $green
echo ""

echo "Importing data to $db_database..."
pv content_dump.sql | mysql -h$db_host -u$db_username -p$db_password $db_database
cecho "[  OK  ]" $green
echo ""

switchBack

echo "Removing $temp..."
sudo rm -Rf $temp
cecho "[  OK  ]" $green
echo ""

./scripts/helper/echoFooter.sh 'Done.'
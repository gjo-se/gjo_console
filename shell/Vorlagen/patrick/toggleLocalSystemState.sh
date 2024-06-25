#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

source scripts/helper/cecho.sh
./scripts/helper/echoHeader.sh "Toggling local system state" "./scripts/toggleLocalSystemState.sh [-a|--activate] [-d|--deactivate]"

db_database=`./scripts/helper/getConfig.sh DB.database`
db_username=`./scripts/helper/getConfig.sh DB.username`
db_password=`./scripts/helper/getConfig.sh DB.password`
db_host=`./scripts/helper/getConfig.sh DB.host`
db_databasemetadata="metadata"

config_deactivate=0
config_activate=0
while test $# -gt 0; do
        case "$1" in
                -d|--deactivate)
                        config_deactivate=1
                        config_activate=0
                        shift
                        ;;
                -a|--activate)
                        config_deactivate=0
                        config_activate=1
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

cd web > /dev/null;

if [ $config_activate == 0 ] && [ $config_deactivate == 0 ]; then
    cecho "[ FAIL ] No action passed" $red
    echo ""
fi;

if [ $config_deactivate == 1 ]; then
    echo "Deactivating local system..."
    mysql -u$db_username -p$db_password -h$db_host $db_databasemetadata -e "UPDATE maintenance SET active=1;"
    cecho "[  OK  ]" $green
    echo ""
fi;

if [ $config_activate == 1 ]; then
    echo "Activating local system..."
    mysql -u$db_username -p$db_password -h$db_host $db_databasemetadata -e "UPDATE maintenance SET active=0;"
    cecho "[  OK  ]" $green
    echo ""
fi;

cd - > /dev/null

./scripts/helper/echoFooter.sh 'Done.'


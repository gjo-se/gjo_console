#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi

if [[ ! $1 =~ ^[a-z]{2}-[A-Z]{2}$ ]]; then
    echo "Please specify an isocode."
    echo "USAGE: source scripts/deployProductdataToLive.sh isocode [-f|--force]"
    exit 1
fi

function switchBack()
{
    echo "Switching back to origin folder..."
    cd - > /dev/null
    cecho "[  OK  ]" $green
    echo ""
}

./scripts/helper/echoHeader.sh 'Deploy productdata to LIVE'
source scripts/helper/cecho.sh
source scripts/helper/alert.sh

db_database=`./scripts/helper/getConfig.sh DB.database`
db_username=`./scripts/helper/getConfig.sh DB.username`
db_password=`./scripts/helper/getConfig.sh DB.password`
db_host=`./scripts/helper/getConfig.sh DB.host`
db_databaselive="productdata"

tables=();
tables[0]="tx_kaercherproducts_domain_model_application"
tables[1]="tx_kaercherproducts_domain_model_benefit"
tables[2]="tx_kaercherproducts_domain_model_dictionary"
tables[3]="tx_kaercherproducts_domain_model_feature"
tables[4]="tx_kaercherproducts_domain_model_icon"
tables[5]="tx_kaercherproducts_domain_model_prat"
tables[7]="tx_kaercherproducts_domain_model_productgrouptext"
tables[8]="tx_kaercherproducts_domain_model_productgrouptitle"
tables[9]="tx_kaercherproducts_domain_model_productinfo"
tables[10]="tx_kaercherproducts_domain_model_property"
tables[11]="tx_kaercherproducts_domain_model_techdata"
tables[12]="tx_kaercherproducts_domain_model_text"
tables[13]="tx_kaercherproducts_domain_model_uvp"

isocode="$1"
isocodeimport="${isocode}-import"

folder="$(basename "`pwd`")"
if [ "$folder" != "cms-prod-worker.app.kaercher.com" ]; then
    db_usernamelive=$db_username
    db_passwordlive=$db_password
    db_hostlive=$db_host
else
    db_usernamelive=`./scripts/helper/getConfig.sh DB.username LIVE`
    db_passwordlive=`./scripts/helper/getConfig.sh DB.password LIVE`
    db_hostlive=`./scripts/helper/getConfig.sh DB.host LIVE`
fi

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

cecho "This script will deploy productdata to LIVE!!!" $yellow
echo ""

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

if [ "$config_force" != "1" ]; then
    echo "Generating security code, please wait..."
    code=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-6} | head -n 1`
    cecho "[  OK  ]" $green
    echo ""

    echo "To make sure you know what you're doing please enter the following code: $code"
    read input
    echo ""

    if [ "$code" != "$input" ]; then
        cecho "[ FAIL ] Code check failed." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
fi

cecho "= SOURCE =" $magenta
echo "Isocode: $isocode"
echo "Mysql-Host: $db_host"
echo "Database: $db_database"
echo ""

cecho "= TARGET =" $magenta
echo "Import-Isocode: $isocodeimport"
echo "Mysql-Host: $db_hostlive"
echo "Database: $db_databaselive"
echo ""

if [ "$config_force" != "1" ]; then
    echo "Start database transfer now? [y|n]:"
    read start
    echo ""

    if [ $start != 'y' ] && [ $start != 'Y' ]; then
        cecho "[ FAIL ] Deployment aborted" $red
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

echo "Creating data dump for $isocode..."
mysqldump -u$db_username -p$db_password -h$db_host --replace --skip-add-drop-table --lock-tables=false --skip-add-locks --where="isocode='$isocode'" --no-create-info $db_database ${tables[*]} > data.sql
cecho "[  OK  ]" $green
echo ""

echo "Checking data dump..."
grep -e "-- Dump completed" data.sql > /dev/null
if [ $? -ne 0 ]; then
    switchBack
    sendAlert "Productdata deployment failed" "Export failed."

    cecho "[ FAIL ] Export failed" $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

echo "Creating mm dump for $isocode..."
mysqldump -u$db_username -p$db_password -h$db_host --replace --skip-add-drop-table --skip-add-locks --no-create-info --lock-tables=false --where="uid_local IN (SELECT uid from tx_kaercherproducts_domain_model_feature WHERE isocode='$isocode')" $db_database tx_kaercherproducts_feature_benefit_mm > mm.sql
cecho "[  OK  ]" $green
echo ""

echo "Checking data dump..."
grep -e "-- Dump completed" mm.sql > /dev/null
if [ $? -ne 0 ]; then
    switchBack
    sendAlert "Productdata deployment failed" "Export failed."

    cecho "[ FAIL ] Export failed" $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

echo "Cleaning up the database..."
for table in ${tables[*]}
do
    echo "- $table"
    mysql -u$db_usernamelive -p$db_passwordlive -h$db_hostlive $db_databaselive -e "DELETE FROM $table WHERE isocode='$isocodeimport';"
done
cecho "[  OK  ]" $green
echo ""

echo "Changing isocode to $isocodeimport..."
sudo sed -i "s/'$isocode'/'$isocodeimport'/g" data.sql
cecho "[  OK  ]" $green
echo ""

echo "Importing data dump..."
pv data.sql | mysql -u$db_usernamelive -p$db_passwordlive -h$db_hostlive $db_databaselive
cecho "[  OK  ]" $green
echo ""

echo "Removing old mm data..."
mysql -u$db_usernamelive -p$db_passwordlive -h$db_hostlive $db_databaselive -e "DELETE FROM tx_kaercherproducts_feature_benefit_mm WHERE uid_local IN (SELECT uid from tx_kaercherproducts_domain_model_feature WHERE isocode='$isocode')"
cecho "[  OK  ]" $green
echo ""

echo "Importing mm dump..."
pv mm.sql | mysql -u$db_usernamelive -p$db_passwordlive -h$db_hostlive $db_databaselive
cecho "[  OK  ]" $green
echo ""

echo "Switching from $isocodeimport to $isocode..."
for table in ${tables[*]}
do
    echo "- $table"
    mysql -u$db_usernamelive -p$db_passwordlive -h$db_hostlive $db_databaselive -e "DELETE FROM $table WHERE isocode='$isocode'; UPDATE $table SET isocode='$isocode' WHERE isocode='$isocodeimport';"
done
cecho "[  OK  ]" $green
echo ""

switchBack

echo "Removing $temp..."
sudo rm -Rf $temp
cecho "[  OK  ]" $green
echo ""

./scripts/helper/echoFooter.sh 'Done.'
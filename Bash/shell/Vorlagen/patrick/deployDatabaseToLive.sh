#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi

function switchBack()
{
    echo "Switching back to origin folder..."
    cd - > /dev/null
    cecho "[  OK  ]" $green
    echo ""
}

./scripts/helper/echoHeader.sh 'Deploy database to LIVE'
source scripts/helper/cecho.sh
source scripts/helper/alert.sh

db_database=`./scripts/helper/getConfig.sh DB.database`
db_username=`./scripts/helper/getConfig.sh DB.username`
db_password=`./scripts/helper/getConfig.sh DB.password`
db_host=`./scripts/helper/getConfig.sh DB.host`
hmac_key="zT_E5{e"

ignorabletables=();
ignorabletables[0]="sys_log"
ignorabletables[1]="sys_history"
ignorabletables[2]="tx_kaerchercentralcontrol_domain_model_duplicationmapping"
ignorabletables[3]="tx_kaerchercommerceconnector_domain_model_offer"
ignorabletables[4]="tx_kaercherproducts_domain_model_application"
ignorabletables[5]="tx_kaercherproducts_domain_model_benefit"
ignorabletables[6]="tx_kaercherproducts_domain_model_dictionary"
ignorabletables[7]="tx_kaercherproducts_domain_model_feature"
ignorabletables[8]="tx_kaercherproducts_domain_model_icon"
ignorabletables[9]="tx_kaercherproducts_domain_model_prat"
ignorabletables[10]="tx_kaercherproducts_domain_model_productgrouptext"
ignorabletables[11]="tx_kaercherproducts_domain_model_productgrouptitle"
ignorabletables[12]="tx_kaercherproducts_domain_model_productinfo"
ignorabletables[13]="tx_kaercherproducts_domain_model_property"
ignorabletables[14]="tx_kaercherproducts_domain_model_salesdata"
ignorabletables[15]="tx_kaercherproducts_domain_model_techdata"
ignorabletables[16]="tx_kaercherproducts_domain_model_text"
ignorabletables[17]="tx_kaercherproducts_domain_model_uvp"
ignorabletables[18]="tx_kaercherproducts_feature_benefit_mm"
ignorabletables[19]="tx_kaerchercentralcontrol_domain_model_s3index"
ignorabletables[20]="tx_kaerchercentralcontrol_domain_model_s3index_staging"

config_force=0
config_clients=()
db_version=1
while test $# -gt 0; do
        case "$1" in
                -f|--force)
                        config_force=1
                        shift
                        ;;
                -c|--client)
                        shift
                        config_clients+=($1)
                        shift
                        ;;
                -v|--version)
                        shift
                        db_version=$1
                        shift
                        ;;
                *)
                        shift
                        ;;
        esac
done

folder="$(basename "`pwd`")"
if [ "$folder" != "cms-prod-worker.app.kaercher.com" ]; then
    db_databaselive=$db_database
    db_usernamelive=$db_username
    db_passwordlive=$db_password
    db_hostlive=$db_host
else
    db_databaselive="globalwebsiteprod"
    db_usernamelive=`./scripts/helper/getConfig.sh DB.username LIVE`
    db_passwordlive=`./scripts/helper/getConfig.sh DB.password LIVE`
    db_hostlive=`./scripts/helper/getConfig.sh DB.host LIVE`
fi

db_databaselivemetadata="metadata"
db_databaseliveimport="${db_databaselive}_$db_version"
now=`date +'%Y-%m-%d %H:%M:%S'`

ignorearg=""
ignoreargimport=""
for ignorabletable in ${ignorabletables[*]}
do
    ignorearg+=" --ignore-table=$db_database.$ignorabletable"
    ignoreargimport+=" --ignore-table=$db_databaseliveimport.$ignorabletable"
done

cecho "This script will deploy a release to LIVE!!!" $yellow
echo ""

echo "Checking curl installation..."
curlinstalled=`command -v curl `
if [ -z "$curlinstalled" ]; then
    cecho "[ FAIL ] curl is not installed." $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

echo "Checking openssl installation..."
opensslinstalled=`command -v openssl `
if [ -z "$opensslinstalled" ]; then
    cecho "[ FAIL ] openssl is not installed." $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
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
echo "Mysql-Host: $db_host"
echo "Database: $db_database"
echo "Ignore-Arg: $ignorearg"
echo ""

cecho "= TARGET =" $magenta
echo "Mysql-Host: $db_hostlive"
echo "Database: $db_databaselive"
echo "Import-Database: $db_databaseliveimport"
echo "Clients: ${config_clients[*]}"
echo "Ignore-Arg: $ignoreargimport"
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

echo "Creating schema dump from $db_database..."
mysqldump -u$db_username -p$db_password -h$db_host $db_database -d --lock-tables=false > schema_dump.sql
cecho "[  OK  ]" $green
echo ""

echo "Creating data dump from $db_database..."
mysqldump -u$db_username -p$db_password -h$db_host $db_database $ignorearg --lock-tables=false --no-create-info > content_dump.sql
cecho "[  OK  ]" $green
echo ""

echo "Checking data dump from $db_database..."
grep -e "-- Dump completed" content_dump.sql > /dev/null
if [ $? -ne 0 ]; then
    switchBack
    sendAlert "Deployment failed" "Export failed."

    cecho "[ FAIL ] Export failed" $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

echo "Creating database $db_databaseliveimport..."
mysql -h$db_hostlive -u$db_usernamelive -p$db_passwordlive -e "CREATE DATABASE \`$db_databaseliveimport\` COLLATE 'utf8_general_ci';"
cecho "[  OK  ]" $green
echo ""

echo "Importing schema to $db_databaseliveimport..."
pv schema_dump.sql | mysql -h$db_hostlive -u$db_usernamelive -p$db_passwordlive $db_databaseliveimport
cecho "[  OK  ]" $green
echo ""

echo "Importing data to $db_databaseliveimport..."
pv content_dump.sql | mysql -h$db_hostlive -u$db_usernamelive -p$db_passwordlive $db_databaseliveimport
cecho "[  OK  ]" $green
echo ""

if [ "$folder" == "cms-prod-worker.app.kaercher.com" ]; then
    echo "Waiting for the RDS to be in sync..."
    sleep 120
    cecho "[  OK  ]" $green
    echo ""
fi

if [ "$config_force" != "1" ]; then
    echo "Switch versions now? If not you have to delete the databases $db_databaseliveimport and the temp folder $temp manually! [y|n]:"
    read switch
    echo ""

    if [ $switch != 'y' ] && [ $switch != 'Y' ]; then
        switchBack

        cecho "[ FAIL ] Deployment aborted" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
fi

switchBack

echo "Removing $temp..."
sudo rm -Rf $temp
cecho "[  OK  ]" $green
echo ""

for uid_client in ${config_clients[*]}
do
    country=`mysql -h$db_hostlive -u$db_usernamelive -p$db_passwordlive $db_databaselivemetadata -e "SELECT country FROM connection WHERE uid_client=$uid_client" --column-names=false -B`
    version=`mysql -h$db_hostlive -u$db_usernamelive -p$db_passwordlive $db_databaselivemetadata -e "SELECT version FROM connection WHERE uid_client=$uid_client" --column-names=false -B`
    tstamp=$(date +%s)
    hmac=`echo -n "$db_version-$tstamp" | openssl sha1 -hmac "$hmac_key" | awk '{print \$2}'`

    echo "Calling apache via cURL to create basic cache entries for client $country [$uid_client]..."
    curlcmd="curl -L -G -d \"versionoverride=$db_version&hmac=$hmac&tstamp=$tstamp&id=contact\" -w \"%{http_code}\" -o /dev/null --retry 1 --retry-delay 60 "
    if [ "$folder" != "cms-prod-worker.app.kaercher.com" ]; then
        curlcmd+="--noproxy localhost --header \"Host: $folder\" http://localhost/${country,,}/notextistingpage.html"
    else
        curlcmd+="http://cms-prod.app.kaercher.com/${country,,}/notextistingpage.html"
    fi

    echo "Cmd: $curlcmd"
    status=`eval $curlcmd 2> /dev/null`

    # try again after timeout
    if [ "$status" == "000" ]; then
        cecho "[ FAIL ] Timeout, retrying..." $red

        sleep 60
        status=`eval $curlcmd 2> /dev/null`
    fi

    if [ "$status" != "200" ]; then
        sendAlert "Deployment failed for client $uid_client" "cURL request for client $country [$uid_client] failed with statuscode $status"

        cecho "[ FAIL ] Status: $status" $red
        echo ""
    else
        cecho "[  OK  ]" $green
        echo ""

        echo "Saving connection history for client $country [$uid_client]..."
        mysql -h$db_hostlive -u$db_usernamelive -p$db_passwordlive $db_databaselivemetadata -e "INSERT INTO connection_history (\`uid_client\`, \`version\`, \`until\`) VALUES ($uid_client, $version, '$now');"
        cecho "[  OK  ]" $green
        echo ""

        echo "Updating $db_databaselivemetadata for client $country [$uid_client]..."
        mysql -h$db_hostlive -u$db_usernamelive -p$db_passwordlive $db_databaselivemetadata -e "UPDATE connection SET version='$db_version' WHERE uid_client=$uid_client"
        cecho "[  OK  ]" $green
        echo ""
    fi
done

echo "Cleanup the database..."
./scripts/cleanupLiveDatabase.sh > /dev/null
cecho "[  OK  ]" $green
echo ""

./scripts/helper/echoFooter.sh 'Done.'
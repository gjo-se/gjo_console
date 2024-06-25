#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi

./scripts/helper/echoHeader.sh 'Cleanup the LIVE database'
source scripts/helper/cecho.sh
source scripts/helper/alert.sh

folder="$(basename "`pwd`")"
if [ "$folder" != "cms-prod-worker.app.kaercher.com" ]; then
    db_database=`./scripts/helper/getConfig.sh DB.database`
    db_username=`./scripts/helper/getConfig.sh DB.username`
    db_password=`./scripts/helper/getConfig.sh DB.password`
    db_host=`./scripts/helper/getConfig.sh DB.host`
else
    echo "Checking aws installation..."
    awsinstalled=`command -v aws`
    if [ -z "$awsinstalled" ]; then
        cecho "[ FAIL ] aws is not installed." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
    cecho "[  OK  ]" $green
    echo ""

    db_database="globalwebsiteprod"
    db_username=`./scripts/helper/getConfig.sh DB.username LIVE`
    db_password=`./scripts/helper/getConfig.sh DB.password LIVE`
    db_host=`./scripts/helper/getConfig.sh DB.host LIVE`
fi

db_databasemetadata='metadata'
databases=$(echo `mysql -h$db_host -u$db_username -p$db_password -e "SHOW DATABASES LIKE '${db_database}_%';" --column-names=false -B` | tr "\n" " ")
versions=$(echo `mysql -h$db_host -u$db_username -p$db_password $db_databasemetadata -e "SELECT version FROM connection GROUP BY version" --column-names=false -B` | tr "\n" " ")

for database in ${databases[*]}
do
    found=0
    for version in ${versions[*]}
    do
        if [ "$database" == "${db_database}_$version" ]; then
            found=1
            break
        fi
    done

    if [ $found -ne  1 ]; then
        filename=LIVE_${database}
        filenameAndPath=backups/${filename}

        echo "Creating dump from $database..."
        mysqldump -u$db_username -p$db_password -h$db_host $database > $filenameAndPath.sql
        cecho "[  OK  ]" $green
        echo ""

        echo "Checking dump from $database..."
        grep -e "-- Dump completed" ${filenameAndPath}.sql > /dev/null
        if [ $? -ne 0 ]; then
            sendAlert Cleanup "Export failed."

            cecho "[ FAIL ] Export failed" $red
            echo ""
        else
            cecho "[  OK  ]" $green
            echo ""

            echo "Creating backup archive in ${filename}.tar.gz"
            tar cfz ${filenameAndPath}.tar.gz ${filenameAndPath}.sql
            cecho "[  OK  ]" $green
            echo ""

            echo "Removing ${filename}.sql"
            rm ${filenameAndPath}.sql
            cecho "[  OK  ]" $green
            echo ""

            if [ "$folder" == "cms-prod-worker.app.kaercher.com" ]; then
                echo "Transfering archive using awscli"
                aws s3 cp ${filenameAndPath}.tar.gz s3://redesign-cms/backups/${filename}.tar.gz
                cecho "[  OK  ]" $green
                echo ""

                echo "Removing ${filename}.tar.gz"
                rm ${filenameAndPath}.tar.gz
                cecho "[  OK  ]" $green
                echo ""
            fi;

            echo "Dropping database $database..."
            mysql -h$db_host -u$db_username -p$db_password -e "DROP DATABASE $database;"
            cecho "[  OK  ]" $green
            echo ""
        fi
    fi
done

./scripts/helper/echoFooter.sh 'Done.'
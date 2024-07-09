#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

filename=`date +%d-%m-%Y_%H-%M-%S`

source scripts/helper/cecho.sh
./scripts/helper/echoHeader.sh "Creating backup ${filename}" "./scripts/createBackup.sh [-t|--transfer]"

echo "Checking aws installation..."
awsinstalled=`command -v aws`
if [ -z "$awsinstalled" ]; then
    cecho "[ FAIL ] aws is not installed." $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

config_transfer=0
while test $# -gt 0; do
        case "$1" in
                -t|--transfer)
                        config_transfer=1
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

filenameAndPath=backups/${filename}
db_database=`./scripts/helper/getConfig.sh DB.database`
db_username=`./scripts/helper/getConfig.sh DB.username`
db_password=`./scripts/helper/getConfig.sh DB.password`
db_host=`./scripts/helper/getConfig.sh DB.host`

if [ ! -d "backups" ]; then
	echo "Creating backups folder"
        mkdir backups;
	cecho "[  OK  ]" $green
	echo ""
fi;

echo "Creating database backup in ${filename}.sql"
mysqldump -u"$db_username" -p"$db_password" -h $db_host --ignore-table=${db_database}.sys_log --ignore-table=${db_database}.be_sessions --ignore-table=${db_database}.fe_sessions --ignore-table=${db_database}.fe_session_data --ignore-table=${db_database}.cache_md5params --ignore-table=${db_database}.cache_treelist --ignore-table=${db_database}.cache_typo3temp_log --ignore-table=${db_database}.cf_cache_hash --ignore-table=${db_database}.cf_cache_hash_tags --ignore-table=${db_database}.cf_cache_pages --ignore-table=${db_database}.cf_cache_pagesection --ignore-table=${db_database}.cf_cache_pagesection_tags --ignore-table=${db_database}.cf_cache_pages_tags --ignore-table=${db_database}.cf_cache_rootline --ignore-table=${db_database}.cf_cache_rootline_tags --ignore-table=${db_database}.cf_extbase_datamapfactory_datamap --ignore-table=${db_database}.cf_extbase_datamapfactory_datamap_tags --ignore-table=${db_database}.cf_extbase_object --ignore-table=${db_database}.cf_extbase_object_tags --ignore-table=${db_database}.cf_extbase_reflection --ignore-table=${db_database}.cf_extbase_reflection_tags --ignore-table=${db_database}.cf_extbase_typo3dbbackend_tablecolumns --ignore-table=${db_database}.cf_extbase_typo3dbbackend_tablecolumns_tags $db_database > ${filenameAndPath}.sql
cecho "[  OK  ]" $green
echo ""

echo "Creating uploads backup in ${filename}.tar"
tar cf ${filenameAndPath}.tar web/fileadmin/ web/uploads/
cecho "[  OK  ]" $green
echo ""

echo "Creating backup archive in ${filename}.tar.gz"
tar cfz ${filenameAndPath}.tar.gz ${filenameAndPath}.tar ${filenameAndPath}.sql
cecho "[  OK  ]" $green
echo ""

echo "Removing single backup files"
rm ${filenameAndPath}.tar
rm ${filenameAndPath}.sql
cecho "[  OK  ]" $green
echo ""

if [ $config_transfer == 1 ]; then
    echo "Transfering archive using awscli"
    aws s3 cp ${filenameAndPath}.tar.gz s3://redesign-cms/backups/${filename}.tar.gz
    cecho "[  OK  ]" $green
    echo ""

    echo "Removing ${filenameAndPath}.tar.gz"
    rm ${filenameAndPath}.tar.gz
    cecho "[  OK  ]" $green
    echo ""
fi;

./scripts/helper/echoFooter.sh 'Done.'


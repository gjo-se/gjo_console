#!/bin/bash

cacheFolders[0]="web/typo3temp/Cache/"

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

./scripts/helper/echoHeader.sh "Clearing the cache" "./scripts/clearCache.sh [-d|--dbonly] [-f|--filesonly]"

source scripts/helper/cecho.sh

config_dbonly=0
config_filesonly=0
while test $# -gt 0; do
        case "$1" in
                -d|--dbonly)
                        config_dbonly=1
                        cecho "-- Clearing database only --" $magenta
                        echo ""
                        shift
                        ;;
                -f|--filesonly)
                        config_filesonly=1
                        cecho "-- Clearing cache files only --" $magenta
                        echo ""
                        shift
                        ;;
                *)
                        shift
                        ;;
        esac
done

if [ $config_dbonly == 0 ]; then
    for folder in "${cacheFolders[@]}"
    do
    echo "Deleting cache files folder $folder..."
        if [ -d "$folder" ]; then
            rm -Rf $folder
            cecho "[  OK  ]" $green
        else
            cecho "[ FAIL ] Folder does not exist" $red
        fi;
        echo ""
    done
fi;

if [ $config_filesonly == 0 ]; then
    echo "Clearing local redis cache..."
    redis-cli FLUSHALL &>/dev/null
    cecho "[  OK  ]" $green
    echo ""
fi;

./scripts/helper/echoFooter.sh 'Done.'

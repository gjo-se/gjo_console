#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

filename=`date +%d-%m-%Y_%H-%M-%S`

source scripts/helper/cecho.sh
./scripts/helper/echoHeader.sh "Create feed" "./scripts/createFeeds.sh [-t|--transfer]"

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

echo "Creating feed..."
cd web > /dev/null
sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_search -a createfeedfiles > /dev/null
cd - > /dev/null
cecho "[  OK  ]" $green
echo ""

if [ $config_transfer == 1 ]; then
    echo "Checking aws installation..."
    awsinstalled=`command -v aws`
    if [ -z "$awsinstalled" ]; then
        cecho "[ FAIL ] aws is not installed." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
    cecho "[  OK  ]" $green
    echo ""

    echo "Transfering rewritemaps using awscli"
    aws s3 sync web/datafeed/ s3://redesign-cms/sync/datafeed/
    cecho "[  OK  ]" $green
fi;

./scripts/helper/echoFooter.sh 'Done.'


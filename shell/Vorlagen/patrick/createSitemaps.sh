#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

source scripts/helper/cecho.sh
./scripts/helper/echoHeader.sh "Create sitemaps" "./scripts/createSitemaps.sh"

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

echo "Creating sitemaps..."
cd web > /dev/null
sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_sitemap > /dev/null
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

    echo "Transfering sitemaps using awscli"
    aws s3 sync web/sitemaps/ s3://redesign-cms/sync/sitemaps/
    cecho "[  OK  ]" $green
fi;

./scripts/helper/echoFooter.sh 'Done.'


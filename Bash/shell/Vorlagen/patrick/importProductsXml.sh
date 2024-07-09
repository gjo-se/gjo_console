#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

source scripts/helper/cecho.sh

./scripts/helper/echoHeader.sh 'Import products xml'

echo "The file to import from typo3temp folder:"
find web/typo3temp/ -maxdepth 2 -name "WWW_*.xml" -type f -printf "%P\n"
read file
echo ""

if [ -f "web/typo3temp/$file" ]; then
        cmd="php typo3/cli_dispatch.phpsh kaercher_products -a importxmlfile -f typo3temp/$file -k"
    else
        cecho "[ FAIL ] The file does not exist" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
fi;

echo "Run as a service? [y|n]:"
read asservice
echo ""

if [ $asservice == 'y' ] || [ $asservice == 'Y' ]; then
    echo "Starting sudo (because the import will run as a service)..."
    sudo echo "test" > /dev/null
    cecho "[  OK  ]" $green
    echo ""
fi;

echo "Command: sudo -E -u "www-data" -g "www-data" $cmd"
echo "Start import now? [y|n]:"
read start
echo ""

if [ $start == 'y' ] || [ $start == 'Y' ]; then
        cd web > /dev/null

        if [ $asservice == 'y' ] || [ $asservice == 'Y' ]; then
            echo "Starting worker process (running in the background)..."
            cecho "Can only be stopped by calling 'killall php'" $yellow
            sudo -E -u www-data -g www-data $cmd > /dev/null &
        else
            echo "Starting worker..."
            sudo -E -u www-data -g www-data $cmd
        fi;

        cd - > /dev/null

        cecho "[  OK  ]" $green
        echo ""
    else
        cecho "[ FAIL ] Import aborted" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
fi;

./scripts/helper/echoFooter.sh 'Done.'
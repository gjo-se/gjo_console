#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

source scripts/helper/cecho.sh

./scripts/helper/echoHeader.sh 'Import products data'

config_force=0
while test $# -gt 0; do
        case "$1" in
                -f|--force)
                        config_force=1
                        echo ""
                        shift
                        ;;
                *)
                        shift
                        ;;
        esac
done

if [ "$config_force" != "1" ]; then
    echo "Start import now? [y|n]:"
    read start
    echo ""

    if [ $start != 'y' ] && [ $start != 'Y' ]; then
        cecho "[ FAIL ] Import aborted" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi;
fi;

echo "Starting sudo (because the import will run as a service)..."
sudo echo "test" > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Starting worker process (running in the background)..."
cecho "Can only be stopped by calling 'killall php'" $yellow
cd web > /dev/null
sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_products -a importproductsdata > /dev/null &
cd - > /dev/null

./scripts/helper/echoFooter.sh 'Done.'
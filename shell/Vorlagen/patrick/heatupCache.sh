#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

usage="./scripts/heatupCache.sh [-r|--restart] PATH"

./scripts/helper/echoHeader.sh 'Heating up the cache' "$usage"
source scripts/helper/cecho.sh

config_restart=0
while test $# -gt 0; do
        case "$1" in
                -r|--restart)
                        config_restart=1
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

folder="$(basename "`pwd`")"
if [ "$folder" != "cms-stage.app.kaercher.com" ]; then
    localhost=1
    host=$folder
else
    localhost=0
    host="www.kaercher.com"
fi;

cmdMain="php typo3/cli_dispatch.phpsh kaercher_central_control -a heatupcache -h $host -p $1"
if [ $localhost == 1 ]; then
    cmdMain="$cmdMain -l"
fi;

cmdWorker="php typo3/cli_dispatch.phpsh kaercher_central_control -a heatupcacheworker -h $host"

echo "Command: $cmdMain"

cd web > /dev/null

if [ $config_restart == 0 ]; then
    echo "Starting main process..."
    sudo -E -u www-data -g www-data $cmdMain
    cecho "[  OK  ]" $green
    echo ""
fi;

echo "Starting worker processes (running in the background)..."
cecho "Can only be stopped by calling 'killall php'" $yellow
for i in {1..5}
do
   sudo -E -u www-data -g www-data $cmdWorker &>/dev/null &
done
cecho "[  OK  ]" $green

cd - > /dev/null


./scripts/helper/echoFooter.sh 'Done.'
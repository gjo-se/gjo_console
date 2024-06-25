#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

usage="./scripts/startStaticFileCacheWorker.sh [-k|--keepalive]"

./scripts/helper/echoHeader.sh "Start static file cache worker" "$usage"
source scripts/helper/cecho.sh
source scripts/helper/alert.sh

config_instances=5
config_keepalive=0
while test $# -gt 0; do
        case "$1" in
                -k|--keepalive)
                        config_keepalive=1
                        shift
                        ;;
                *)
                        shift
                        ;;
        esac
done

cmdWorker="php typo3/cli_dispatch.phpsh kaercher_deployment -a startstaticfilecacheworker &>/dev/null &"
echo "Command: $cmdWorker"
echo ""

start=5
if [ "$config_keepalive" == "1" ]; then
	start=0
	processes=$((($(ps aux | grep 'startstaticfilecacheworker' | awk '{print $2}' | wc -l) - 1) / 2))
	if [ "$processes" -lt "$config_instances" ]; then
		start=$(($config_instances - $processes))

		if [ "$start" -gt "0" ]; then
			sendAlert "Static file cache worker restarted" "$start worker(s) had to be restarted."
		fi
	fi
else
	echo "Terminating remaining worker processes..."
	sudo kill $(ps aux | grep 'startstaticfilecacheworker' | awk '{print $2}')
	cecho "[  OK  ]" $green
	echo ""
fi

echo "Starting $start worker processes (running in the background)..."
cd web > /dev/null

i=0
while [ "$i" -lt "$start" ]; do
   sudo -E -u www-data -g www-data $cmdWorker &>/dev/null &
   i=$(($i + 1))
done

cd - > /dev/null
cecho "[  OK  ]" $green
echo ""

./scripts/helper/echoFooter.sh 'Done.'
#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

source scripts/helper/cecho.sh

usage="./scripts/benchmarkLocalSystem.sh HOST [-p|--path PATH] [-l|--loadtest]"
if [ -z $1 ]; then
    echo "Please specify a host."
    echo "USAGE: $usage"
    echo "EXAMPLE: ./scripts/benchmarkLocalSystem.sh cms.vm-dev.kaercher.com"
    exit 1
fi;

config_loadtest=0
config_path='/'
config_host=''
while test $# -gt 0; do
        case "$1" in
                -l|--loadtest)
                        config_loadtest=1
                        shift
                        ;;
                -p|--path)
                        shift
                        config_path=$1
                        shift
                        ;;
                *)
                        config_host=$1
                        shift
                        ;;
        esac
done

./scripts/helper/echoHeader.sh "Benchmark local environment [$config_host]" $usage

echo "Unsetting proxy settings..."
old_http_proxy=$http_proxy
old_https_proxy=$https_proxy
old_HTTP_PROXY=$HTTP_PROXY
old_HTTPS_PROXY=$HTTPS_PROXY
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
cecho "[  OK  ]" $green
echo ""

echo "Clearing cache files..."
./scripts/clearCache.sh -f &>/dev/null
cecho "[  OK  ]" $green
echo ""

echo "Regenerating cache files..."
ab -H "Host: $config_host" localhost/ > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Clearing cache database..."
./scripts/clearCache.sh -d &>/dev/null
cecho "[  OK  ]" $green
echo ""

echo "Running benchmark (uncached, 1 request)..."
echo "Command: ab -H \"Host: $config_host\" localhost$config_path"
ab -H "Host: $config_host" localhost/$2 | grep 'Time per request:'
cecho "[  OK  ]" $green
echo ""

echo "Running benchmark (cached, 1 request)..."
echo "Command: ab -H \"Host: $config_host\" localhost$config_path"
ab -H "Host: $config_host" localhost/$2 | grep 'Time per request:'
cecho "[  OK  ]" $green
echo ""

if [ $config_loadtest == 1 ]; then
    echo "Running loadtest (cached, 100 request, 2 simultaneously)..."
    echo "Command: ab -n 100 -c 2 -H \"Host: $config_host\" localhost$config_path"
    ab -n 100 -c 2 -H "Host: $config_host" localhost/$2 | grep 'Time per request:'
    end=$(date +%s)
    cecho "[  OK  ]" $green
    echo ""
fi;

./scripts/helper/echoFooter.sh "Done."
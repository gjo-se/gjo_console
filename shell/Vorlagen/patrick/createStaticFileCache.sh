#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

usage="./scripts/createStaticFileCache.sh -c CLIENTUIDS [-t|--transfer]"

./scripts/helper/echoHeader.sh "Create static file cache" "$usage"
source scripts/helper/cecho.sh

if [ -z $1 ]; then
    echo "Please specify a client uid."
    echo "USAGE: $usage"
    exit 1
fi;


config_transfer=0
config_clients=0
while test $# -gt 0; do
        case "$1" in
                -c|--clients)
                        shift
                        config_clients=$1
                        shift
                        ;;
                -t|--transfer)
                        config_transfer=1
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

version=`cat config/content_version.txt`
targetfile="`printf \"%08d\n\" $version`.tar.gz"
currentfile="current.tar.gz"

echo "Starting sudo..."
sudo echo "test" > /dev/null
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

    echo "Clearing static folder..."
    sudo rm -Rf static/*
    cecho "[  OK  ]" $green
    echo ""

    for i in 1 2 3; do
        echo "Downloading $currentfile using awscli - try ${i}..."
        aws s3 cp s3://ak-globalwebsite-deploy/$currentfile static/ --profile deploy

        if [ ! -f static/$currentfile ]; then
            sleep 30
        else
            break
        fi
    done

    if [ ! -f static/$currentfile ]; then
        sendAlert "Deployment failed" "Download failed."

        cecho "[ FAIL ] Download failed" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    else
        cecho "[  OK  ]" $green
        echo ""
    fi

    echo "Extracting and removing $currentfile..."
    cd static > /dev/null
    sudo tar xfz $currentfile
    if [[ $? -ne 0 ]]; then
        sendAlert "Deployment failed" "Extraction failed."

        cecho "[ FAIL ] Extraction failed" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    else
        sudo rm $currentfile
        cd - > /dev/null
        cecho "[  OK  ]" $green
        echo ""
    fi

    echo "Fixing permissions..."
    sudo chmod 777 -R static/
    cecho "[  OK  ]" $green
    echo ""
fi

echo "Starting worker processes (running in the background)..."
bash scripts/startStaticFileCacheWorker.sh > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Starting crawler..."
cd web > /dev/null
sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_deployment -a createstaticfilecache -c $config_clients
cd - > /dev/null
cecho "[  OK  ]" $green
echo ""

if [ $config_transfer == 1 ]; then
    echo "Creating targetfile..."
    if [ -f static/$currentfile ]; then
        sudo rm static/$currentfile
    fi

    cd static > /dev/null
    sudo tar cfz $currentfile *
    if [[ $? -ne 0 ]]; then
        sendAlert "Deployment failed" "Packing failed."

        cecho "[ FAIL ] Packing failed" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi

    cd - > /dev/null
    cecho "[  OK  ]" $green
    echo ""

    echo "Uploading $currentfile file using awscli..."
    aws s3 cp static/$currentfile s3://ak-globalwebsite-deploy/ --profile deploy
    sudo rm static/$currentfile
    cecho "[  OK  ]" $green
    echo ""

    echo "Copying $currentfile to $targetfile file using awscli..."
    aws s3 cp s3://ak-globalwebsite-deploy/$currentfile s3://ak-globalwebsite-deploy/$targetfile --profile deploy
    cecho "[  OK  ]" $green
fi

./scripts/helper/echoFooter.sh 'Done.'
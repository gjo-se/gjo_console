#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

source scripts/helper/cecho.sh

./scripts/helper/echoHeader.sh 'Sync from S3'

echo "Checking aws installation..."
awsinstalled=`command -v aws`
if [ -z "$awsinstalled" ]; then
    cecho "[ FAIL ] aws is not installed." $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

echo "Syncing sitemaps using awscli"
sudo rm web/sitemaps/*
aws s3 sync s3://redesign-cms/sync/sitemaps/ web/sitemaps/
sudo chown www-data:www-data web/sitemaps/ -R
cecho "[  OK  ]" $green
echo ""

echo "Syncing rewritemaps using awscli"
# aws cli tools do not check the hashed dbm files correctly, so we have to delete all files first
sudo rm rewritemaps/*
aws s3 sync s3://redesign-cms/sync/rewritemaps/ rewritemaps/
sudo chown www-data:www-data rewritemaps/ -R
cecho "[  OK  ]" $green
echo ""

./scripts/helper/echoFooter.sh 'Done.'
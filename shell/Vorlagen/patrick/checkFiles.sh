#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

if [ ! -f "checksum.md5" ]; then
	echo "checksum.md5 does not exist"
	exit 1
fi;

./scripts/helper/echoHeader.sh "Checking files using `pwd`/checksum.md5"

source scripts/helper/cecho.sh

echo "Checking files..."
fails=`md5sum -c checksum.md5 | grep 'FAILED'`

if [ -n "$fails" ]; then
    echo $fails
    cecho "[FAILED]" $red
else
    cecho "[  OK  ]" $green
fi;

./scripts/helper/echoFooter.sh 'Done.'
#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit
fi;

source scripts/helper/alert.sh
sendAlert $1 $2
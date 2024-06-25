#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi;

source scripts/helper/cecho.sh
./scripts/helper/echoHeader.sh "Revise product documents" "./scripts/reviseProductDocuments.sh"

cd web

echo "Processing manuals..."
sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_products -a revisemanuals > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Processing datasheets..."
sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_products -a revisedatasheets > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Processing energylabels..."
sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_products -a reviseenergylabels > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Processing EU datasheets..."
sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_products -a reviseeudatasheets > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Processing safety datasheets..."
sudo -E -u www-data -g www-data php typo3/cli_dispatch.phpsh kaercher_products -a revisesafetydatasheets > /dev/null
cecho "[  OK  ]" $green
echo ""

cd - > /dev/null

./scripts/helper/echoFooter.sh 'Done.'


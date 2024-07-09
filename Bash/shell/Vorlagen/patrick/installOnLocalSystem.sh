#!/bin/bash

symlinks[0]="../config/.htaccess:web/.htaccess"
symlinks[1]="typo3_src/index.php:web/index.php"
symlinks[2]="typo3_src/typo3:web/typo3"
symlinks[3]="../typo3_src/:web/typo3_src"
symlinks[4]="../../config/$1/LocalConfiguration.php:web/typo3conf/LocalConfiguration.php"
symlinks[5]="../../config/$1/PackageStates.php:web/typo3conf/PackageStates.php"
symlinks[6]="../../config/$1/settings:web/fileadmin/settings"
symlinks[7]="../frontend/:frontend"
symlinks[8]="$1/Environment.php:../jobruntime/src/Configuration/Environment.php"
symlinks[9]="../../../../core/:../jobruntime/vendor/Kaercher/CMS/Core"
symlinks[10]="../../../../core/:../frontend/vendor/Kaercher/CMS/Core"

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi

source scripts/helper/cecho.sh

if [ -z $1 ]; then
    echo "Please specify a system environment."
    echo "USAGE: ./scripts/installOnLocalSystem.sh ENVIRONMENT"
    exit 1
fi

./scripts/helper/echoHeader.sh "Installing on local environment [$1]"

for symlink in "${symlinks[@]}"
do
    arr=($(echo $symlink | tr ":" " "))

    echo "Creating symlink for ${arr[0]} in ${arr[1]}..."
    if [ ! -L "${arr[1]}" ]; then
        sudo ln -s ${arr[0]} ${arr[1]}
        cecho "[  OK  ]" $green
    else
        cecho "[ FAIL ] Symlink already exists" $red
    fi
    echo ""
done


echo "Applying TYPO3 Core Patch..."
cd typo3_src
sudo patch -N -p0 -r - -i ../patch/TYPO3Core.patch > /dev/null
cd - > /dev/null
cecho "[  OK  ]" $green
echo ""

./scripts/helper/echoFooter.sh "Installation done."
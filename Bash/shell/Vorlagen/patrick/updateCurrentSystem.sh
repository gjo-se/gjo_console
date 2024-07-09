#!/bin/bash

# Do not use any external scripts here!
# This one has to be standalone!

usage="./scripts/updateCurrentSystem.sh path environment"
example="./scripts/updateCurrentSystem.sh /var/www/cms-prod.app.kaercher.com LIVE"
if [ -z $1 ]; then
    echo "Please specify a path."
    echo "USAGE: $usage"
    echo "EXAMPLE: $example"
    exit 1
fi

if [ -z $2 ]; then
    echo "Please specify the environment."
    echo "USAGE: $usage"
    echo "EXAMPLE: $example"
    exit 1
fi

pathTYPO3=$1
environment=$2
deploymentpath="s3://redesign-cms/deployment/"
archivefile="code.tar.gz"
archivechecksumfile="code.md5"
installscript="./scripts/installOnLocalSystem.sh"
syncfroms3script="./scripts/syncFromS3.sh"
cronfile="/etc/cron.d/kaercher"

root=`dirname $pathTYPO3`
pathCore="$root/core"
pathFrontend="$root/frontend"
pathJobRuntime="$root/jobruntime"

temp="/tmp/deployment"
tempTYPO3="$temp/typo3"
tempCore="$temp/core"
tempFrontend="$temp/frontend"
tempJobRuntime="$temp/jobruntime"

crons=()
crons[0]="0 0 * * * root /usr/sbin/ntpdate pool.ntp.org &> /dev/null"
crons[1]="0 */6 * * * root cd $pathTYPO3; ./scripts/syncFromS3.sh &> /dev/null"
crons[2]="*/10 * * * * root cd $pathJobRuntime/src; bash Scripts/KeepProcessAlive.sh -c Logging/GearmanWorker -q 2 &> /dev/null"
crons[3]="0 0 * * * root find /var/www/cms-prod.app.kaercher.com/web/typo3temp/kaercher_assetmanager/ -mtime +2 -exec rm {} \; &> /dev/null"

echo "== Update current system =="
echo ""

echo "Checking target path..."
if [ ! -d "$pathTYPO3" ]; then
    echo "[ FAIL ] $pathTYPO3 does not exist."
    exit 1
fi
echo "[  OK  ]"
echo ""

echo "Checking temp path..."
if [ ! -d "$temp" ]; then
    echo "[ FAIL ] $temp does not exist."
    exit 1
fi
echo "[  OK  ]"
echo ""

echo "Checking rsync installation..."
rsyncinstalled=`command -v rsync`
if [ -z "$rsyncinstalled" ]; then
    echo "[ FAIL ] rsync is not installed."
    exit 1
fi
echo "[  OK  ]"
echo ""

echo "Creating folders $pathCore, $pathFrontend, $pathJobRuntime..."
sudo mkdir $pathCore &> /dev/null
sudo mkdir $pathFrontend &> /dev/null
sudo mkdir $pathJobRuntime &> /dev/null
echo "[  OK  ]"
echo ""

echo "Switching to $temp..."
cd $temp > /dev/null
echo "[  OK  ]"
echo ""

echo "Checking $archivefile with $archivechecksumfile..."
fails=`md5sum -c $archivechecksumfile | grep 'FAILED'`
if [ -n "$fails" ]; then
    echo "[ FAIL ] Checksum failed."
    exit 1;
fi
echo "[  OK  ]"
echo ""

echo "Extracting $archivefile..."
sudo tar xfz $archivefile &> /dev/null
echo "[  OK  ]"
echo ""

echo "Removing $archivefile and $archivechecksumfile..."
sudo rm $archivefile
sudo rm $archivechecksumfile
echo "[  OK  ]"
echo ""

echo "Syncing $tempFrontend to $pathFrontend..."
sudo rsync $tempFrontend/ $pathFrontend -r --quiet
echo "[  OK  ]"
echo ""

echo "Syncing $tempJobRuntime to $pathJobRuntime..."
sudo rsync $tempJobRuntime/ $pathJobRuntime -r --quiet
echo "[  OK  ]"
echo ""

echo "Syncing $tempCore to $pathCore..."
sudo rsync $tempCore/ $pathCore -r --quiet
echo "[  OK  ]"
echo ""

echo "Syncing $tempTYPO3 to $pathTYPO3..."
sudo rsync $tempTYPO3/ $pathTYPO3 -r --quiet --exclude 'updateCurrentSystem.sh'
echo "[  OK  ]"
echo ""

echo "Changing owner of $pathCore, $pathJobRuntime, $pathFrontend, $pathTYPO3..."
sudo chown www-data:www-data $pathCore $pathJobRuntime $pathFrontend $pathTYPO3 -R
echo "[  OK  ]"
echo ""

echo "Switching to $pathTYPO3..."
cd $pathTYPO3 > /dev/null
echo "[  OK  ]"
echo ""

echo "Clearing $temp..."
sudo rm -Rf $temp/*
echo "[  OK  ]"
echo ""

echo "Removing cache_core files..."
sudo rm $pathTYPO3/web/typo3temp/Cache/Code/cache_core/*
echo "[  OK  ]"
echo ""

echo "Fixing permissions..."
sudo chmod +x scripts/*.sh
sudo chmod 777 rewritemaps
sudo chmod 777 web/sitemaps
echo "[  OK  ]"
echo ""

echo "Executing installation script..."
$installscript $environment &> /dev/null
echo "[  OK  ]"
echo ""

echo "Executing syncFromS3 script..."
$syncfroms3script &> /dev/null
echo "[  OK  ]"
echo ""

if [ "$environment" == "LIVE" ]; then
    echo "Removing old cron file..."
    if [ -e $cronfile ]; then
        sudo rm $cronfile
        echo "[  OK  ]"
    else
      echo "[ FAIL ] File does not exist"
    fi
    echo ""

    echo "Writing new cron file..."
    for cron in "${crons[@]}"
    do
        sudo sh -c "echo \"$cron\" >> $cronfile"
    done
    echo "[  OK  ]"
    echo ""

    echo "Reloading cron daemon..."
    sudo service cron reload
    echo "[  OK  ]"
    echo ""
fi

ps -C apache2 > /dev/null
if [ $? -eq 0 ]; then
    echo "Reloading apache2..."
    sudo service apache2 reload &> /dev/null
    echo "[  OK  ]"
    echo ""
else
    echo "Starting apache2..."
    sudo service apache2 start &> /dev/null
    echo "[  OK  ]"
    echo ""
fi

echo "== Done =="
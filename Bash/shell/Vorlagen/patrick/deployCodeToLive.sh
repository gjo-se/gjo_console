#!/bin/bash

if [ ! -d "web" ] || [ ! -d "scripts" ]; then
	echo "Please execute from root folder!"
	exit 1
fi

deploymentpath="s3://redesign-cms/deployment/"
versionfile="config/code_version.txt"
archivefile="code.tar.gz"
archivechecksumfile="code.md5"
updatescriptfile="scripts/updateCurrentSystem.sh"

./scripts/helper/echoHeader.sh 'Deploy code to LIVE'
source scripts/helper/cecho.sh

cecho "This script will deploy a release to LIVE!!!" $yellow
echo ""

origin=`pwd`
development=1
folder="$(basename "`pwd`")"
if [ "$folder" == "cms-stage-worker.app.kaercher.com" ]; then
    development=0
fi

echo "Checking svn installation..."
svninstalled=`command -v svn`
if [ -z "$svninstalled" ]; then
    cecho "[ FAIL ] svn is not installed." $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi
cecho "[  OK  ]" $green
echo ""

if [ $development -eq 0 ]; then
    echo "Checking awscli installation..."
    awscliinstalled=`command -v aws`
    if [ -z "$awscliinstalled" ]; then
        cecho "[ FAIL ] awscli is not installed." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
    cecho "[  OK  ]" $green
    echo ""

    echo "Is your system time '`date`' correct [y|n]:"
    read systemtimecorrect

    if [ $systemtimecorrect != 'y' ] && [ $systemtimecorrect != 'Y' ]; then
        echo ""
        echo "Please enter the current time in the syntax 'YYYY-mm-dd h:m':"
        read newsystemtime

        if [ -z "$newsystemtime" ]; then
            cecho "[ FAIL ] No time given." $red
            ./scripts/helper/echoFooter.sh 'Failed.'
            exit 1
        fi

        echo ""
        echo "Setting system time..."
        sudo date --set="$newsystemtime"
    fi
    cecho "[  OK  ]" $green
    echo ""

    echo "Checking deployment path $deploymentpath..."
    lss3=`aws s3 ls $deploymentpath`
    if [ -z "$lss3" ]; then
        cecho "[ FAIL ] The deployment path $deploymentpath is not available on S3." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
    cecho "[  OK  ]" $green
    echo ""

    echo "Generating security code, please wait..."
    code=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-6} | head -n 1`
    cecho "[  OK  ]" $green
    echo ""

    echo "To make sure you know what you're doing please enter the following code: $code"
    read input
    echo ""

    if [ "$code" != "$input" ]; then
        cecho "[ FAIL ] Code check failed." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
fi

echo "Please give the version of the release (https://svn.app.kaercher.com/svn/ak-cms/branches/releases/[version]):"
read releaseversion
echo ""

if [ -z "$releaseversion" ]; then
    cecho "[ FAIL ] No version given." $red
    ./scripts/helper/echoFooter.sh 'Failed.'
    exit 1
fi

echo "Please give the version of the code (leave empty to use $releaseversion):"
read codeversion
echo ""

if [ -z "$codeversion" ]; then
    codeversion=$releaseversion
fi

branchTYPO3="https://svn.app.kaercher.com/svn/ak-cms/branches/releases/$releaseversion"
branchCore="https://svn.app.kaercher.com/svn/ak-cms/branches/releases/core"
branchFrontend="https://svn.app.kaercher.com/svn/ak-cms/branches/releases/frontend"
branchJobRuntime="https://svn.app.kaercher.com/svn/ak-cms/branches/releases/jobruntime"

if [ $development -eq 0 ]; then
    echo "Checking branch $branchTYPO3..."
    svn ls $branchTYPO3 &> /dev/null
    error=$?
    if [ $error -ne 0 ]; then
        cecho "[ FAIL ] The branch $branchTYPO3 does not exist." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
    cecho "[  OK  ]" $green
    echo ""

    echo "Checking if $branchTYPO3/$updatescriptfile exists..."
    svn ls "$branchTYPO3/$updatescriptfile" &> /dev/null
    error=$?
    if [ $error -ne 0 ]; then
        cecho "[ FAIL ] Update script not found." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
    cecho "[  OK  ]" $green
    echo ""

    tag="https://svn.app.kaercher.com/svn/ak-cms/tags/releases/$releaseversion"
    echo "Checking tag $tag..."
    svn ls $tag &> /dev/null
    error=$?
    if [ $error -ne 1 ]; then
        cecho "[ FAIL ] The tag $tag does already exist." $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi
    cecho "[  OK  ]" $green
    echo ""

    echo "Deploy now (never ever cancel the process with 'CTRL + C')? [y|n]:"
    read start
    echo ""

    if [ $start != 'y' ] && [ $start != 'Y' ]; then
        cecho "[ FAIL ] Deployment aborted" $red
        ./scripts/helper/echoFooter.sh 'Failed.'
        exit 1
    fi

    echo "Creating tag $tag from branch $branchTYPO3..."
    svn cp $branchTYPO3 $tag -m "000 | created tag for release $releaseversion"
    cecho "[  OK  ]" $green
    echo ""
fi

temp="/tmp/deployment_`date +%s`"
tempTYPO3="$temp/typo3"
tempCore="$temp/core"
tempFrontend="$temp/frontend"
tempJobRuntime="$temp/jobruntime"
echo "Creating temp folders..."
sudo mkdir -p $tempTYPO3
sudo mkdir -p $tempCore
sudo mkdir -p $tempFrontend
sudo mkdir -p $tempJobRuntime
sudo chmod 0777 $temp -R
cecho "[  OK  ]" $green
echo ""

echo "Exporting $branchCore to $tempCore..."
svn export $branchCore $tempCore --force -q
cecho "[  OK  ]" $green
echo ""

echo "Exporting $branchFrontend to $tempFrontend..."
svn export $branchFrontend $tempFrontend --force -q
cecho "[  OK  ]" $green
echo ""

echo "Exporting $branchJobRuntime to $tempJobRuntime..."
svn export $branchJobRuntime $tempJobRuntime --force -q
cecho "[  OK  ]" $green
echo ""

echo "Exporting $branchTYPO3 to $tempTYPO3..."
svn export $branchTYPO3 $tempTYPO3 --force -q
cecho "[  OK  ]" $green
echo ""

echo "Switching to $tempTYPO3..."
cd $tempTYPO3 > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Fixing encoding of all scripts..."
sudo ./scripts/dos2UnixOnScriptsFolder.sh &> /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Updating version information in $versionfile..."
printf $codeversion > $versionfile
cecho "[  OK  ]" $green
echo ""

echo "Switching to $temp..."
cd $temp > /dev/null
cecho "[  OK  ]" $green
echo ""

echo "Creating archive $archivefile..."
tar cfz $archivefile *
cecho "[  OK  ]" $green
echo ""

echo "Creating checksum file for $archivefile..."
md5sum $archivefile > $archivechecksumfile
cecho "[  OK  ]" $green
echo ""

if [ $development -eq 0 ]; then
    echo "Transfering $archivefile, $archivechecksumfile and $updatescriptfile to $deploymentpath..."
    aws s3 cp $archivefile $deploymentpath --quiet
    aws s3 cp $archivechecksumfile $deploymentpath --quiet
    aws s3 cp $tempTYPO3/$updatescriptfile $deploymentpath --quiet
    cecho "[  OK  ]" $green
    echo ""
fi

echo "Switching back to $origin..."
cd $origin > /dev/null
cecho "[  OK  ]" $green
echo ""

if [ $development -eq 0 ]; then
    echo "Removing $temp..."
    sudo rm -Rf $temp
    cecho "[  OK  ]" $green
    echo ""
fi

./scripts/helper/echoFooter.sh 'Done.'
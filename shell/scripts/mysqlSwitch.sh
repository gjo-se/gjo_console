#!/usr/bin/env bash

#######################################
### HELPER                          ###
#######################################

# https://gist.github.com/benlinton/d24471729ed6c2ace731
# https://github.com/Homebrew/legacy-homebrew
# https://github.com/Homebrew/homebrew-boneyard/tree/master/cmd


# brew -v # => Homebrew 0.9.5

# # Install current mysql version
# brew install mysql

# unset TMPDIR
# mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp

# Find older mysql versions
# brew search mysql

# Install older mysql version
# brew install homebrew/versions/mysql56

# brew services start mysql
# brew services restart mysql
# brew services list

# Folder:
# /usr/local/var/mysql/
#

#######################################
### SWITCH                          ###
#######################################

VERSION_FROM="$1"
VERSION_TO="$2"
CURRENT_VERSION="57"

# TODO: VERSION_TO => VERSION (nur die neue Version eingeben (VERSION_FROm entfält)
# TODO: CURRENT_VERSION ist die aktuell laifende => muss aufgelesen werden,


if [ x$VERSION_FROM = x ] ;
    then
        echo "Parameter \$VERSION_FROM angeben! - mysqlSwitch xx or check 57"
    else

        if [ $VERSION_FROM == "check" ] ;
            then
                ls -l /usr/local/bin/mysql
            else

            if [ $VERSION_FROM == $CURRENT_VERSION ] ;
                then
                    echo "Parameter ist 57"
                    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
                    rm ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

                    brew unlink mysql
                else
                    echo "Parameter ist $VERSION_FROM"
                    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql$VERSION_FROM.plist
                    rm ~/Library/LaunchAgents/homebrew.mxcl.mysql$VERSION_FROM.plist

                    brew unlink mysql$VERSION_FROM
            fi


            if [ x$VERSION_TO = x ] ;
                then
                    echo "Parameter \$VERSION_TO angeben! - mysqlSwitch 57 xx"
                else

                    if [ $VERSION_TO == $CURRENT_VERSION ] ;
                        then
                            echo "Parameter TO ist 57"
                            LONG_VERSION=$(ls /usr/local/Cellar/mysql)

                            echo LONG VERSION: ${LONG_VERSION}
                            brew switch mysql ${LONG_VERSION}

                            ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
                            launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

                        else
                            echo "Parameter TO ist $VERSION_FROM"

                            LONG_VERSION=$(ls /usr/local/Cellar/mysql$VERSION_TO)

                            echo LONG VERSION: ${LONG_VERSION}
                            brew switch mysql$VERSION_TO ${LONG_VERSION}

                            ln -sfv /usr/local/opt/mysql$VERSION_TO/*.plist ~/Library/LaunchAgents
                            launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql$VERSION_TO.plist


                    fi
            fi

        fi
fi


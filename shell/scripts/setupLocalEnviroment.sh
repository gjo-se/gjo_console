#!/usr/bin/env bash

. ~/.bash_profile


#TODO: das ist der Apache aus dem Host, kann ich so auf der VM nicht gebrauchen, da aus YAML
# - also FunktionenNamen anpassen
# - Verzeichnisse für Lokale Installion anpassen / einfügen ??!!


setupBash_profile() {
    if [ -f $EXT_PATH/gjo_enviroment/dev/System/bash/.bash_profile ];
            then
                e_error "Error: .bash_profile already exits in Extension."
            else
                mv ~/.bash_profile $BASH_DIR
                ln -s $BASH_DIR/.bash_profile ~/
                mv ~/.bash_history $BASH_DIR
                ln -s $BASH_DIR/.bash_history ~/
                e_success "Success:" \
                    "Moved ~/.bash_profile in gjo_enviroment and set Symlink back" \
                    "Moved ~/.bash_history in gjo_enviroment and set Symlink back"
    fi
}

setup_apache() {

ORIGINAL_FOLDER="/etc"

#

    if [ -d $EXT_PATH/gjo_enviroment/dev/System/apache2 ];
            then
                e_error "Error: apache2/ Folder already exits in Extension."
            else
                sudo mv $ORIGINAL_FOLDER/apache2/ $BASH_DIR/
                sudo ln -s $BASH_DIR/apache2/ /etc/
                e_success "Success:" \
                    "Moved $ORIGINAL_FOLDER/php in gjo_enviroment and set Symlink back"
    fi
}

setup_php() {

ORIGINAL_FOLDER="/usr/local/etc"

    if [ -d $EXT_PATH/gjo_enviroment/dev/System/php ];
            then
                e_error "Error: php/ Folder already exits in Extension."
            else
                sudo mv $ORIGINAL_FOLDER/php $BASH_DIR/
                sudo ln -s $BASH_DIR/php/ $ORIGINAL_FOLDER/
                e_success "Success:" \
                    "Moved $ORIGINAL_FOLDER in gjo_enviroment and set Symlink back"
    fi
}

setup_mysql() {

ORIGINAL_FOLDER="/usr/local/etc"
# weitere Optionen siehe _HP_ELITE/XAMPP-182/MYSQL/bin/my.ini:
# You can copy this file to
# C:/xampp-182/mysql/bin/my.cnf to set global options,
# mysql-data-dir/my.cnf to set server-specific options (in this
# installation this directory is C:/xampp-182/mysql/data) or
# ~/.my.cnf to set user-specific options.

# global options,
# /etc/my.cnf
# /etc/mysql/my.cnf
# ~/.my.cnf

    if [ -d $EXT_PATH/gjo_enviroment/dev/System/mysql ];
            then
                e_error "Error: mysql/ Folder already exits in Extension."
            else
                mkdir $BASH_DIR/mysql
                sudo mv $ORIGINAL_FOLDER/my.cnf $BASH_DIR/mysql/
                sudo ln -s $BASH_DIR/mysql/my.cnf $ORIGINAL_FOLDER/
                e_success "Success:" \
                    "Moved $ORIGINAL_FOLDER in gjo_enviroment and set Symlink back"
    fi
}

setup_phpstorm_settings() {

# https://www.jetbrains.com/help/phpstorm/2016.1/project-and-ide-settings.html

    if [ -d $EXT_PATH/gjo_enviroment/dev/System/phpstorm ];
            then
                e_error "Error: phpstorm/ Folder already exits in Extension."
            else
                mkdir -p $BASH_DIR/phpstorm/{Application\ Support,Preferences}

                sudo mv ~/Library/Application\ Support/PhpStorm2016.1 $BASH_DIR/phpstorm/Application\ Support/
                sudo ln -s $BASH_DIR/phpstorm/Application\ Support/PhpStorm2016.1 ~/Library/Application\ Support/

                sudo mv ~/Library/Preferences/PhpStorm2016.1 $BASH_DIR/phpstorm/Preferences/
                sudo ln -s $BASH_DIR/phpstorm/Preferences/PhpStorm2016.1 ~/Library/Preferences/

                e_success "Success:" \
                    "Moved $ORIGINAL_FOLDER in gjo_enviroment and set Symlink back"
    fi
}

if [ "$1" == "" ] ;
    then
        setupBash_profile
        setup_apache
        setup_php
        setup_mysql
        setup_phpstorm_settings
fi

while test $# -gt 0; do
        case "$1" in
                "bash")
                    setupBash_profile
                    shift
                    ;;
                "apache")
                    setup_apache
                    shift
                    ;;
                "php")
                    setup_php
                    shift
                    ;;
                "mysql")
                    setup_mysql
                    shift
                    ;;
                "storm")
                    setup_phpstorm_settings
                    shift
                    ;;
                *)
                    e_error "$1 is not a valid Paramter"
                    break
                    ;;
        esac
done
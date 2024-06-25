#!/usr/bin/env bash

. ~/.bash_profile

#######################################
### IDEE                            ###
#######################################

# übergabe: Projekt, EXT
# EXT Symlink anlegen
# Abfangen: Projekt leer oder nicht vorhanden
# TODO 3. Parameter: EXT installieren
# 		php typo3/cli_dispatch.phpsh extbase extension:install extensionName

#######################################
### Code                            ###
#######################################

PROJECT="$1"
PROJECT_PATH=~/Documents/Dropbox/5-Berufsleben/gjoSe/Development/Projects
EXT="$2"
EXT_PATH=~/Documents/Dropbox/5-Berufsleben/gjoSe/Development/localRepositories/ext

if [ "$1" == "" ] ;

    then
	    e_error "The first Parameter must be an valid project."
	    echo "--------------Projects:-------------------------------------------------------------"
	        ll $PROJECT_PATH
	        echo "--------------Extensions:-----------------------------------------------------------"
	        ls $EXT_PATH
	    exit
	else
	    if [ "$PROJECT" == show ];
	        then
	        echo "--------------Projects:-------------------------------------------------------------"
	        ll $PROJECT_PATH
	        echo "--------------Extensions:-----------------------------------------------------------"
	        ls $EXT_PATH
	        exit
        fi
	    if [ ! -d $PROJECT_PATH/$PROJECT  ];
            then
                echo "Error: $PROJECT is not a project."
            exit
        fi;
fi;

if [ x$EXT = x ];
    then
	    echo "The second Parameter must be an valid extension."
	    exit
	else
	    if [ ! -d $EXT_PATH/$EXT  ];
            then
                echo "Error: $EXT is not a valid extension."
            exit
        fi;

        if [ -d $PROJECT_PATH/$PROJECT/typo3conf/ext/$EXT  ];
            then
                echo "Error: $EXT is already linked to Project: $PROJECT."
            exit
        fi;
fi;

ln -s $EXT_PATH/$EXT $PROJECT_PATH/$PROJECT/typo3conf/ext/
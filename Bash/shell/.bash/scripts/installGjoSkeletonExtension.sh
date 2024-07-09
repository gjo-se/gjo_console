#!/usr/bin/env bash

. ~/.bash_profile

#######################################
### IDEE                            ###
#######################################

# Parameter: Projekt, EXT_KEY
# Copy gjo_skeleton
# TODO: wenn innerhjalb eines Projektes, dieses nehmen
#ist doch aber falsch - oder Projektabhängig!
# eventuell Copy oder Symlink
# TODO 3. Parameter: EXT installieren, geht an der Stelle nicht, da die ext_emconf noch fehlt
#       php $PROJECT_PATH/$PROJECT/typo3/cli_dispatch.phpsh extbase extension:install $EXT_KEY

#######################################
### Code                            ###
#######################################

PROJECT="$1"
PROJECT_PATH=~/Documents/Dropbox/5-Berufsleben/Development/Projects
EXT_PATH=~/Documents/Dropbox/5-Berufsleben/Development/localRepositories/ext
GJO_SKELETON='gjo_skeleton'
EXT_KEY="$2"

if [ "$PROJECT" == "" ] ;

    then
	    e_error "Error: The first Parameter must be an valid project."
	    echo "--------------Projects:-------------------------------------------------------------"
	        ll $PROJECT_PATH
	    exit
	else
	    if [ ! -d $PROJECT_PATH/$PROJECT  ];
            then
                e_error "Error: $PROJECT is not a project."
            echo "--------------Projects:-------------------------------------------------------------"
                ll $PROJECT_PATH
            exit
        fi;
fi;

if [ "$EXT_KEY" == "" ] ;

    then
	    e_error "Error: The second Parameter must be an valid ext_key."
	    echo "--------------Projects:-------------------------------------------------------------"
	        ll $PROJECT_PATH/$PROJECT/typo3conf/ext/
	    exit
	else
	    if [ -d $PROJECT_PATH/$PROJECT/typo3conf/ext/$EXT_KEY  ];
            then
                e_error "Error: $EXT_KEY already exists."
            echo "--------------Projects:-------------------------------------------------------------"
                ll $PROJECT_PATH/$PROJECT/typo3conf/ext/
            exit
        fi;
fi;


cpdir $EXT_PATH/$GJO_SKELETON $PROJECT_PATH/$PROJECT/typo3conf/ext/$EXT_KEY
rm $PROJECT_PATH/$PROJECT/typo3conf/ext/$EXT_KEY/.gitignore
rm -rf $PROJECT_PATH/$PROJECT/typo3conf/ext/$EXT_KEY/.git/
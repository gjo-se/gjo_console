#!/usr/bin/env bash

#EXT_PATH=~/Documents/Dropbox/5-Berufsleben/Development/localRepositories/ext

. ~/.bash_profile
# TEST repo/private

#CREATE SCHEMA `test_typo3_762` DEFAULT CHARACTER SET utf8 ;
#
#projectName=test-typo3-762
#
#cd projectName
#mkdir _works
#ln -s ~/Documents/Dropbox/5-Berufsleben/Development/localRepositories/ext/gjo_enviroment typo3conf/ext/
#mkdir typo3conf/ext/gjo_enviroment/dev/test-typo3-762/
#
## TODO: das Ziel innerhalb des Projekt ist Schwachsinn => ins EXT-Verzeichnis,
## CONST anlegen
## besser über source CONST laden
## mv typo3conf/LocalConfiguration.php typo3conf/ext/gjo_enviroment/dev/test-typo3-762/
#
#ln -s ~/Documents/Dropbox/5-Berufsleben/Development/localRepositories/ext/gjo_enviroment/dev/Projects/test-typo3-762/LocalConfiguration.php typo3conf/
#
## wie oben
#mv typo3conf/PackageStates.php typo3conf/ext/gjo_enviroment/dev/test-typo3-762/
#
#ln -s ~/Documents/Dropbox/5-Berufsleben/Development/localRepositories/ext/gjo_enviroment/dev/Projects/test-typo3-762/PackageStates.php typo3conf/


e_header "I am a sample script"
e_success "I am a success message"
e_error "I am an error message"
e_warning "I am a warning message"
e_underline "I am underlined text"
e_bold "I am bold text"
e_note "I am a note"


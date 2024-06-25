#!/usr/bin/env bash

. ~/.bash_profile

Release="$1"

check_release() {

    if [ x$Release = x ] ;
        then
            e_error "Error: First Parameter must be a valid Release (7.6.0) "
            read -p "Please try again:" Release
            check_release
        else

            if [ -d $LIBRARY_PATH/typo3/typo3_src-$Release  ];
                then
                    e_error "Error: typo3_src-$Release already loaded."
                    read -p "Please try again:" Release
                    check_release
            fi;
            goto_typo3Libs
            wget get.typo3.org/$Release -O typo3_src-$Release.tar.gz
            tar xzf typo3_src-$Release.tar.gz typo3_src-$Release
            rm -rf typo3_src-$Release.tar.gz
    fi

}

check_release
#!/usr/bin/env bash

#######################################
### HELPER                          ###
#######################################

# HELP:
# https://getgrav.org/blog/macos-mojave-apache-multiple-php-versions

# Switch on CLI
# brew unlink php@5.6 && brew link --force --overwrite php@7.2

# Switch on Apache
# comment / uncomment Line like:
# LoadModule php7_module /usr/local/opt/php@7.1/lib/httpd/modules/libphp7.so


# brew tap homebrew/dupes
# brew tap homebrew/versions
# brew tap homebrew/homebrew-php

# brew install php54
# brew unlink php54
# brew info php54
# brew services start php54


Version="$1"

if [ x$Version = x ] ;
    then
        echo "Parameter \$Version angeben! - phpSwitch 54"
    else
        sphp $Version
fi

#30B 31 Jul 14:36 /usr/local/bin/phar -> ../Cellar/php70/7.0.5/bin/phar


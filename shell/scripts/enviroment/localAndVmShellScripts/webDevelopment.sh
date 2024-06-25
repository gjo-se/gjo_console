#!/usr/bin/env bash

#   ---------------------------------------
#   WEB DEVELOPMENT
#   ---------------------------------------

    alias phpSwitch='sh $BASH_DIR/scripts/phpSwitch.sh'
    alias mysqlSwitch='sh $BASH_DIR/scripts/mysqlSwitch.sh'
    alias installExt='php56 typo3/cli_dispatch.phpsh extbase extension:install'

    # OLD Version El Capitan
    # alias edit_httpd='sudo $EDITOR /etc/apache2/httpd.conf'
    alias edit_httpd='sudo $EDITOR /usr/local/etc/httpd/httpd.conf'
    # besser open in Storm: CMD+Shift g

    alias edit_httpd-vhosts='sudo $EDITOR /etc/apache2/extra/httpd-vhosts.conf'
    alias edit_hosts='sudo $EDITOR /etc/hosts'
    alias edit_sshconfig='$EDITOR ~/.ssh/config'

    alias edit_php="edit_php70"
    alias edit_php56='sudo $EDITOR /usr/local/etc/php/5.6/php.ini'
    alias edit_php70='sudo $EDITOR /usr/local/etc/php/7.0/php.ini'
    alias edit_php71='sudo $EDITOR /usr/local/etc/php/7.1/php.ini'

    alias edit_my_global='sudo $EDITOR /usr/local/etc/my.cnf'

    alias reload_apache='sudo apachectl -k restart'
    alias reload_mysql='sudo mysql.server start'
    # brew services start mariadb

# php braucht: Library not loaded: /usr/local/opt/jpeg/lib/libjpeg.8.dylib
# brew switch libjpeg 8d
# composer / ImageMagic braucht: Library not loaded: /usr/local/opt/jpeg/lib/libjpeg.9.dylib
# brew switch libjpeg 9b

    alias composer='php /usr/local/bin/composer'

#TODO: Funktion jeweils fürs Projekt anlegen
    apacheAccessLog() { tail /var/log/apache2/"$@"-access_log; }
    apacheErrorLog() { tail /var/log/apache2/"$@"-error_log; }
    mysqlErrorLog() { tail /usr/local/var/mysql/Gregorys-MBP.fritz.box.err; }

    httpHeaders () { /usr/bin/curl -I -L $@ ; }             # httpHeaders:      Grabs headers from web page

    #   httpDebug:  Download a web page and show info on what took time
    #   -------------------------------------------------------------------
        httpDebug () { /usr/bin/curl $@ -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\n" ; }


# You can watch the Apache error log in a new Terminal tab/window during
# a restart to see if anything is invalid or causing a problem:
# tail -f /usr/local/var/log/httpd/error_log
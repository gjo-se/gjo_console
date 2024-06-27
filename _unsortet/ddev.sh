#Umbuntu on WIN:
#- user: gregory
#- password: admin
#
#https://ddev.com/get-started/
#############################
### DDEV                  ###
#############################

ddev ssh
ddev composer validate


#############################
### Create a Project 12.4 ###
#############################

### - https://get.typo3.org/version/12

cd C:\Users\gjo\Dropbox\5-Berufsleben\gjoSe\Development\Projects
rm tiger.de
mkdir tiger.de
cd tiger.de
ddev config --project-type=typo3 --docroot=public --php-version 8.1
ddev composer create --no-install "typo3/cms-base-distribution:^12.4"
ddev composer install
ddev get ddev/ddev-phpmyadmin
ddev restart
ddev describe
ddev typo3 setup
ddev launch

############################
### Create a Project 8.7 ###
############################

### - https://get.typo3.org/version/8.7.20
- https://docs.typo3.org/m/typo3/guide-installation/8.7/en-us/QuickInstall/Composer/Index.html
cd C:\Users\gjo\Dropbox\5-Berufsleben\gjoSe\Development\Projects
rm typo3-v8-test
mkdir typo3-v8-test
cd typo3-v8-test
ddev config --project-type=typo3 --docroot=public --php-version 7.4
ddev composer create --no-install "typo3/cms-base-distribution:^8.7"
ddev composer install
ddev typo3 install:setup
ddev launch

############################
### Create a Project 9.5 ###
############################

### - https://get.typo3.org/version/9

cd C:\Users\gjo\Dropbox\5-Berufsleben\gjoSe\Development\Projects
rm typo3-v9-test
mkdir typo3-v9-test
cd typo3-v9-test
ddev config --project-type=typo3 --docroot=public --php-version 7.4
composer require typo3/cms:^8.7

ddev composer create --no-install "typo3/cms-base-distribution:^9.5"
ddev composer install
ddev get ddev/ddev-phpmyadmin 
ddev restart

TYPO3 Setup
Shell: 
 - ddev typo3 setup ?|? ddev typo3 install:setup
 - ddev launch
Alternativ: 
 - per Browser

ddev typo3 cache:flush 
  - geht so nicht

ddev start
- https://ddev.readthedocs.io/en/stable/users/usage/commands/#composer

Code aktualisieren:
- Require TER EXT
ddev composer require apen/additional_scheduler:^1.5 --update-with-dependencies
ddev composer require in2code/femanager:^5.5 --update-with-dependencies
ddev composer require gridelementsteam/gridelements:^9.8 --update-with-dependencies
ddev composer require georgringer/news:^8.6 --update-with-dependencies
ddev composer require sjbr/static-info-tables:^6.9 --update-with-dependencies
ddev composer require helhum/typo3-console:^5.8 --update-with-dependencies 
// Fluid - Problem mit PHP Version => --ignore-platform-reqs
ddev composer require fluidtypo3/fluidpages:^5.0 --update-with-dependencies --ignore-platform-reqs
ddev composer require fluidtypo3/flux:^9.7 --update-with-dependencies --ignore-platform-reqs
ddev composer require fluidtypo3/vhs:^6.1 --update-with-dependencies --ignore-platform-reqs

- symlink gjoSe EXT 
mklink /D Verknüpfung Ziel
mklink /D Verknüpfung Ziel (dei EXT bekomem ich so nicht aktiviert!)
- aber aktivierung geht über console
ddev composer require gjo/gjo-boilerplate:^9.0 --update-with-dependencies


- Copy ProjectFolders
  - _works/
  - build/
  - web/fileadmin/
  - web/uploads/
  - .htaccess (domain anpassen)
  - .htpasswd
  - typo3conf/
    - AdditionalConfiguration.php (anpassen)
Datenbank aktualisieren:
- V9 Dump erstllen
- aktuellen V8 Dump einspielen
- DataBase compare



########################
### Helper           ###
########################
- https://get.typo3.org/misc/composer/helper

ddev -h
ddev describe
ddev stop
ddev delete

ddev clean --all
ddev hostname --remove-inactive
rm -r ~/.ddev

sudo rm /usr/bin/ddev
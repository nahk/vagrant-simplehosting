#!/usr/bin/env bash

echo "Installing sources.list..."
rm -f "/etc/apt/sources.list"
wget -O "/etc/apt/sources.list" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/sources.list"

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install debian-archive-keyring
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes upgrade
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install debconf-utils

## Debconf for mysql ('root')
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

## Debconf for phpmyadmin ('root')
debconf-set-selections <<< 'phpmyadmin phpmyadmin/password-confirm password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/setup-password password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'

DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install apache2 mysql-client mysql-server php5-common libapache2-mod-php5 php5-cli php5-json php5-mysql php5-mcrypt php5-curl php5-gd php5-xsl php5-xmlrpc php-apc php5-intl php5-xdebug phpmyadmin anacron git
rm -rf /var/www
ln -fs /vagrant /var/www

echo "Installing bash aliases..." 
wget -O "/home/vagrant/.bash_aliases" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/bash_aliases"
echo "Installing php settings..." 
wget -O "/etc/php5/mods-available/php-custom.ini" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/php-custom.ini"

a2enmod rewrite
service apache2 restart

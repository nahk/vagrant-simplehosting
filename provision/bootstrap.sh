#!/usr/bin/env bash

autoArchi() {
	if [ -f "/vagrant/composer.json" ] && grep -q '.*"symfony/symfony".*' composer.json
	then
		symfony2Archi
	elif
}

symfony2Archi() {
	
}


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

DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install \
    apache2 \
    mysql-client mysql-server \
    php5-common php5-cli libapache2-mod-php5 php5-mysql \
    php-apc php5-json php5-mcrypt php5-curl php5-xdebug \
    php5-gd php5-xsl php5-xmlrpc php5-intl \
    phpmyadmin  \
    anacron  \
    git \
    vim
rm -rf /var/www
ln -fs /vagrant /var/www

echo "Installing bash aliases..." 
wget -O "/home/vagrant/.bash_aliases" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/bash_aliases"
echo "Installing php settings..." 
wget -O "/etc/php5/mods-available/php-custom.ini" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/php-custom.ini"

a2enmod rewrite


if [ "$1" = "auto" ]
then
	autoArchi
elif [ "$1" = "symfony2" ]
then
	symfony2Archi
fi
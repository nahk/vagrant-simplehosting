#!/usr/bin/env bash

autoArchi() {
	if [ -f "/vagrant/composer.json" ] && grep -q '.*"symfony/symfony".*' "/vagrant/composer.json"
	then
		symfony2Archi
	fi
}

symfony2Archi() {
	echo "Setting Symfony2 architecture..."
	DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install acl
	mkdir /home/vagrant/.symfony2/cache
	mkdir /home/vagrant/.symfony2/logs
	setfacl -R -m u:www-data:rwX -m u:vagrant:rwX cache logs
	setfacl -dR -m u:www-data:rwX -m u:vagrant:rwX cache logs
	rm "/etc/apache2/sites-available/default"
	wget -O "/etc/apache2/sites-available/default" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/symfony/symfony-vhost"
	if [ -f "/vagrant/app/AppKernel.php" ] && ! grep -q '.*/home/vagrant/.*' "/vagrant/app/AppKernel.php"
	then
		sed -i '$d' "/vagrant/app/AppKernel.php"
		wget -O "/tmp/custom-kernel-code" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/symfony/custom-kernel-code"
		cat "/tmp/custom-kernel-code" >> "/vagrant/app/AppKernel.php"		
	fi
	if [ -f "/vagrant/web/app_dev.php"]
	then
		rm "/vagrant/web/app_dev.php"
		wget -O "/etc/apache2/sites-available/default" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/symfony/app_dev.php"
	fi
}

echo "Installing sources.list..."
rm -f "/etc/apt/sources.list"
wget -O "/etc/apt/sources.list" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/common/sources.list"

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
wget -O "/home/vagrant/.bash_aliases" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/common/bash_aliases"
echo "Installing php settings..." 
wget -O "/etc/php5/mods-available/php-custom.ini" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/common/php-custom.ini"

a2enmod rewrite


if [ "$1" = "auto" ]
then
	autoArchi
elif [ "$1" = "symfony2" ]
then
	symfony2Archi
fi

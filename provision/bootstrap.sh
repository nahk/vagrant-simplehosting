#!/usr/bin/env bash

autoArchi() {
	echo " -- Auto detect architecture... -- "
	if [ -f "/vagrant/composer.json" ] && grep -q '.*"symfony/symfony".*' "/vagrant/composer.json"
	then
    	echo " -- Symfony2 detected... -- "
		symfony2Archi
	else
		echo " -- Default archi... -- "
		defaultArchi
	fi
}

symfony2Archi() {
	echo " -- Installing Symfony2 architecture... -- "
	DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install acl
	mkdir -p /home/vagrant/.symfony2/cache
	mkdir -p /home/vagrant/.symfony2/logs
	setfacl -R -m u:www-data:rwX -m u:vagrant:rwX /home/vagrant/.symfony2/cache /home/vagrant/.symfony2/logs
	setfacl -dR -m u:www-data:rwX -m u:vagrant:rwX /home/vagrant/.symfony2/cache /home/vagrant/.symfony2/logs
	rm -f "/etc/apache2/sites-available/default"
	wget -q -O "/etc/apache2/sites-available/default" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/symfony/symfony-vhost"
	if [ -f "/vagrant/app/AppKernel.php" ] && ! grep -q '.*/home/vagrant/.*' "/vagrant/app/AppKernel.php"
	then
		sed -i '$d' "/vagrant/app/AppKernel.php"
		wget -q -O "/tmp/custom-kernel-code" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/symfony/custom-kernel-code"
		cat "/tmp/custom-kernel-code" >> "/vagrant/app/AppKernel.php"		
	fi
	wget -q -O "/vagrant/web/app_dev.php" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/symfony/app_dev.php"
	wget -q -O "/vagrant/.gitignore" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/symfony/gitignore"
}

defaultArchi() {
	wget -q -O "/vagrant/.gitignore" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/common/gitignore"
}

echo " -- Installing sources.list... -- "
rm -f "/etc/apt/sources.list"
wget -q -O "/etc/apt/sources.list" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/common/sources.list"

echo " -- Updating System... -- "
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install debian-archive-keyring
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes upgrade
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install debconf-utils

echo " -- Installing requirements... -- "
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

debconf-set-selections <<< 'phpmyadmin phpmyadmin/password-confirm password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/setup-password password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'

DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install \
    zsh \
    apache2 \
    mysql-client mysql-server \
    php5-common php5-cli libapache2-mod-php5 php5-mysql \
    php-apc php5-json php5-mcrypt php5-curl php5-xdebug \
    php5-gd php5-xsl php5-xmlrpc php5-intl \
    phpmyadmin  \
    anacron  \
    git \
    vim \
    emacs \
    screen
rm -rf /var/www
ln -fs /vagrant /var/www

echo " -- Installing bashrc... -- " 
wget -q -O "/home/vagrant/.bashrc" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/common/bashrc"
echo " -- Installing zshrc... -- " 
wget -q -O "/home/vagrant/.zshrc" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/common/zshrc"
echo " -- Installing emacs conf... -- " 
wget -q -O "/home/vagrant/.emacs" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/common/emacs"
echo " -- Installing php settings... -- " 
wget -q -O "/etc/php5/mods-available/php-custom.ini" "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/resources/common/php-custom.ini"
ln -s "/etc/php5/mods-available/php-custom.ini" /etc/php5/conf.d/php-custom.ini
cp /vagrant/Vagrantfile /vagrant/Vagrantfile.dist

echo " -- Enabling apache2 mod_rewrite... -- "
a2enmod rewrite

if [ "$1" = "auto" ]
then
	autoArchi
elif [ "$1" = "symfony2" ]
then
	symfony2Archi
fi

echo " -- Restarting apache2... -- "
service apache2 restart


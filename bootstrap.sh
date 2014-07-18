#!/usr/bin/env bash
apt-get update -y
apt-get upgrade -y
apt-get install -y apache2 mysql-client mysql-server php5-fpm php5-mysql php-apc php5-intl php5-xdebug phpmyadmin
rm -rf /var/www
ln -fs /vagrant /var/www

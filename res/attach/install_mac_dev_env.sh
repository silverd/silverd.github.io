#!/bin/sh
#author: yuu

echo "Are you sure to start the installation?y/n"
read sure

if [ $sure != "y" ]; then
    exit 1
fi

echo "==========================================="
echo "Installing Homebrew"
echo "==========================================="

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "==========================================="
echo "Installing OhMyZsh"
echo "==========================================="

brew install zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.zshrc
source ~/.zshrc

echo "==========================================="
echo "Installing Basic Library"
echo "==========================================="

brew install wget
brew install libevent
brew link libevent
brew install autoconf
brew install pkg-config
brew install libmemcached

echo "==========================================="
echo "Installing Apache+PHP+Redis+Memcached"
echo "==========================================="

brew install homebrew/apache/httpd24
brew install homebrew/php/php70 --with-apache
brew install memcached
brew install redis
brew install mongodb

echo "==========================================="
echo "Installing PHP Extensions"
echo "==========================================="

brew install --HEAD homebrew/php/php70-memcached
brew install --HEAD homebrew/php/php70-redis
brew install homebrew/php/php70-mongodb
brew install homebrew/php/php70-mcrypt
brew install homebrew/php/php70-xxtea
brew install homebrew/php/php70-yaf
brew install homebrew/php/php70-swoole

echo "==========================================="
echo "Installing PHP Composer"
echo "==========================================="

brew install homebrew/php/composer
composer config -g repo.packagist composer https://packagist.phpcomposer.com

echo "==========================================="
echo "Modifing Config Files"
echo "==========================================="

#php.ini
sed -i '' 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/etc/php/7.0/php.ini

#ext-memcached.ini
sed -i '' -e '/memcached.sess_lock_wait = 150000/d' \
-e '/memcached.sess_lock_max_wait = 0/d' \
/usr/local/etc/php/7.0/conf.d/ext-memcached.ini

echo 'memcached.sess_lock_wait_min = 0;
memcached.sess_lock_wait_max = 0;
memcached.sess_lock_retries = 0;' >> /usr/local/etc/php/7.0/conf.d/ext-memcached.ini

#httpd.conf
sed -i '' \
-e 's/Require all denied/Require all granted/g' \
-e 's/#LoadModule\(.*\)mod_rewrite.so/LoadModule\1mod_rewrite.so/g' \
-e 's/#Include\(.*\)httpd-vhosts.conf/Include\1httpd-vhosts.conf/g' \
-e 's/Listen 8080/Listen 80/g' \
-e 's/#ServerName www.example.com:8080/ServerName localhost/g' \
/usr/local/etc/apache2/2.4/httpd.conf

echo '<IfModule php7_module>
    AddType application/x-httpd-php .php
    AddType application/x-httpd-php-source .phps
    <IfModule dir_module>
        DirectoryIndex index.html index.php
    </IfModule>
</IfModule>' >> /usr/local/etc/apache2/2.4/httpd.conf

mkdir -p ~/home/wwwroot/
cd ~/home/wwwroot/
wwwpath=$(pwd)
echo '<VirtualHost *:80>
    ServerName localhost
    DocumentRoot "'$wwwpath'"
    <Directory "'$wwwpath'">
        Options Indexes FollowSymLinks
        Require all granted
        AllowOverride All
    </Directory>
</VirtualHost>' > /usr/local/etc/apache2/2.4/extra/httpd-vhosts.conf

sudo apachectl restart
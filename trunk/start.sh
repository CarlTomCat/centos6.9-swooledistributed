#!/usr/bin/env bash

/etc/init.d/php-fpm start
/etc/init.d/nginx start
/etc/init.d/redis start
/usr/sbin/sshd
cd /data/wwwroot/trunk
composer install
cd /data/wwwroot/trunk/bin
php start_swoole_server.php stop
php start_swoole_server.php start

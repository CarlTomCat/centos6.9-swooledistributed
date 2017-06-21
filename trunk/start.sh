#!/usr/bin/env bash

/etc/init.d/php-fpm start
/etc/init.d/nginx start
/etc/init.d/redis start
/usr/sbin/sshd
cd /data/wwwroot/trunk
composer install
cd /data/wwwroot/trunk/bin
ps -fe|grep \[s]tart_swoole_server
if [[ $? -ne 0 ]]; then
    php start_swoole_server.php start
else
    echo "start_swoole_server is running..."
fi

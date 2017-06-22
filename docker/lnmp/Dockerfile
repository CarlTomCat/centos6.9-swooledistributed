FROM centos:6.9

# 参数
#ARG website_domain
ARG nginx_port
ARG wwwroot_path
ARG mysql_host
ARG local_host_ip

# 安装 wget, sudo, autoconf, gcc, make
RUN yum install -y wget \
    sudo \
    autoconf \
    gcc \
    make \
    libxslt \
    opensp \
    docbook-style-xsl \
    initscripts \
    re2c \
    libpng \
    graphviz

# package
COPY lnmp1.4.tar.gz /usr/local/src/lnmp1.4.tar.gz
COPY phpredis-php7.zip /usr/local/src/phpredis-php7.zip
COPY epel-release-latest-6.noarch.rpm /usr/local/src/epel-release-latest-6.noarch.rpm
COPY hiredis-0.13.3.tar.gz /usr/local/src/hiredis-0.13.3.tar.gz
COPY inotify-2.0.0.tgz /usr/local/src/inotify-2.0.0.tgz
COPY jemalloc-4.5.0.tar.gz /usr/local/src/jemalloc-4.5.0.tar.gz
COPY swoole-src-1.9.14.tar.gz /usr/local/src/swoole-src-1.9.14.tar.gz
COPY re2c-0.16.tar.gz /usr/local/src/re2c-0.16.tar.gz
COPY xhprof-1.0.tar.gz /usr/local/src/xhprof-1.0.tar.gz
COPY XDEBUG_2_5_4.tar.gz /usr/local/src/XDEBUG_2_5_4.tar.gz

# 为 centos7 增加yum的epel源（redis）
RUN cd /usr/local/src && rpm -ivh epel-release-latest-6.noarch.rpm

# 下载lnmp安装包并安装, PHP>7.0; mysql>5.6
RUN cd /usr/local/src && tar zxf lnmp1.4.tar.gz && cd lnmp1.4 && ./install_lnmp.sh

# 安装 redis
RUN yum install -y redis

# 安装 redis 扩展
RUN cd /usr/local/src && unzip phpredis-php7.zip && cd phpredis-php7 && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make \
    && make install

# 安装 hiredis 扩展
RUN cd /usr/local/src && tar -zxvf hiredis-0.13.3.tar.gz && cd hiredis-0.13.3 \
    && make -j \
    && sudo make install \
    && sudo ldconfig

# 安装 inotify 扩展
RUN cd /usr/local/src && tar -zxvf inotify-2.0.0.tgz && cd inotify-2.0.0 && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make \
    && make install

# 安装 jemalloc 扩展
RUN cd /usr/local/src && tar -zxvf jemalloc-4.5.0.tar.gz && cd jemalloc-4.5.0 \
    && ./autogen.sh \
    && ./configure --with-jemalloc-prefix=je_ \
    && make -j 4

# 安装 xhprof 扩展
RUN cd /usr/local/src && tar -zxvf xhprof-1.0.tar.gz && cd xhprof-1.0/extension && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make \
    && make install

# 安装 xdebug 扩展
RUN cd /usr/local/src && tar -zxvf XDEBUG_2_5_4.tar.gz && cd xdebug-XDEBUG_2_5_4 && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make \
    && make install

# 安装 ssh 服务
RUN yum install -y openssh-server passwd \
    && echo 'root'|passwd root --stdin \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key

# 安装 composer
COPY composer.phar /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://packagist.phpcomposer.com

# 安装 swoole 扩展
RUN cd /usr/local/src && tar -zxvf swoole-src-1.9.14.tar.gz && cd swoole-src-1.9.14 && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config --enable-async-redis --with-jemalloc-dir=/usr/local/src/jemalloc-4.5.0 \
    && make \
    && make install

# 配置 nginx
RUN sed -i "s/localhost/${mysql_host}/" /home/wwwroot/default/phpmyadmin/config.inc.php
COPY xhprof.conf /usr/local/nginx/conf/vhost/xhprof.conf
RUN sed -i "s/include vhost\/\*\.conf;/\# log format\nlog_format access '\$remote_addr - \$remote_user \[\$time_local\] "\$request" '\n    '\$status \$body_bytes_sent "\$http_referer" '\n    '"\$http_user_agent" \$http_x_forwarded_for';\ninclude vhost\/\*\.conf;/" /usr/local/nginx/conf/nginx.conf \
    && sed -i "s/listen 80 default_server;/listen ${nginx_port} default_server;/" /usr/local/nginx/conf/nginx.conf

# 配置 redis
RUN sed -i "s/^# requirepass.*$/requirepass 123456/" /etc/redis.conf

# 配置 php.ini
RUN echo "[xhprof]" >> /usr/local/php/etc/php.ini \
    && echo "extension=xhprof.so" >> /usr/local/php/etc/php.ini \
    && echo "xhprof.output_dir=${wwwroot_path}/xhprof/output" >> /usr/local/php/etc/php.ini \
    && echo "zend_extension=xdebug.so" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.remote_enable=1" >> /usr/local/php/etc/php.ini \
#    && echo "xdebug.remote_connect_back=1" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.remote_host=${local_host_ip}" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.remote_port=9090" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.remote_log=${wwwroot_path}/log/php/xdebug.log" >> /usr/local/php/etc/php.ini \
#    && echo "xdebug.remote_autostart=1" >> /usr/local/php/etc/php.ini \
#    && echo "xdebug.remote_mode=req" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.scream=0" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.show_local_vars=1" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.collect_vars=On" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.collect_return=On" >> /usr/local/php/etc/php.ini \
    && echo "xdebug.collect_params=On" >> /usr/local/php/etc/php.ini \
    && echo "extension=redis.so" >> /usr/local/php/etc/php.ini \
    && echo "extension=inotify.so" >> /usr/local/php/etc/php.ini \
    && echo "extension=swoole.so" >> /usr/local/php/etc/php.ini \
    && sed -i "s/;error_log = php_errors\.log/error_log = \/data\/phplogs\/error.log/" /usr/local/php/etc/php.ini \
    && sed -i "s/disable_functions = passthru,/disable_functions = /" /usr/local/php/etc/php.ini \
    && sed -i "s/proc_open,//" /usr/local/php/etc/php.ini \
    && sed -i "s/proc_get_status,//" /usr/local/php/etc/php.ini

# xdebug 端口
EXPOSE 9090

# 启动 web 环境
CMD /data/wwwroot/trunk/start.sh


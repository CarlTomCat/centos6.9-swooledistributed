FROM centos:6.9

# 参数
ARG website_domain

# 修改 host
RUN echo "127.0.0.1 ${website_domain}" >> /etc/hosts

# 安装 wget, sudo, autoconf, gcc, make
RUN yum install -y wget \
    sudo \
    autoconf \
    gcc \
    make \
    libxslt \
    opensp \
    docbook-style-xsl \
    initscripts

# package
COPY lnmp1.4.tar.gz /usr/local/src/lnmp1.4.tar.gz
COPY phpredis-php7.zip /usr/local/src/phpredis-php7.zip
COPY epel-release-latest-6.noarch.rpm /usr/local/src/epel-release-latest-6.noarch.rpm
COPY hiredis-0.13.3.tar.gz /usr/local/src/hiredis-0.13.3.tar.gz
COPY inotify-2.0.0.tgz /usr/local/src/inotify-2.0.0.tgz
COPY jemalloc-4.5.0.tar.gz /usr/local/src/jemalloc-4.5.0.tar.gz
COPY swoole-src-1.9.13.tar.gz /usr/local/src/swoole-src-1.9.13.tar.gz
COPY re2c-0.16.tar.gz /usr/local/src/re2c-0.16.tar.gz

# 为 centos7 增加yum的epel源（redis）
RUN cd /usr/local/src && rpm -ivh epel-release-latest-6.noarch.rpm

# 安装 re2c
RUN cd /usr/local/src && tar zxf re2c-0.16.tar.gz && cd re2c-0.16 && ./configure && make && make install

# 下载lnmp安装包并安装, PHP>7.0; mysql>5.6
RUN cd /usr/local/src && tar zxf lnmp1.4.tar.gz && cd lnmp1.4 && ./install_lnmp.sh

# 配置 nginx
COPY www.dev.com.conf /usr/local/nginx/conf/vhost/www.dev.com.conf
RUN sed -i "s/include vhost\/\*\.conf;/\# log format\nlog_format access '\$remote_addr - \$remote_user \[\$time_local\] "\$request" '\n    '\$status \$body_bytes_sent "\$http_referer" '\n    '"\$http_user_agent" \$http_x_forwarded_for';\ninclude vhost\/\*\.conf;/" /usr/local/nginx/conf/nginx.conf

# 安装 redis
RUN yum install -y redis

# 安装 redis 扩展
RUN cd /usr/local/src && unzip phpredis-php7.zip && cd phpredis-php7 && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make \
    && make install

# 安装 hiredis
RUN cd /usr/local/src && tar -zxvf hiredis-0.13.3.tar.gz && cd hiredis-0.13.3 \
    && make -j \
    && sudo make install \
    && sudo ldconfig

# 配置 redis
RUN sed -i "s/^# requirepass.*$/requirepass 123456/" /etc/redis.conf

# 安装 inotify 扩展
RUN cd /usr/local/src && tar -zxvf inotify-2.0.0.tgz && cd inotify-2.0.0 && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make \
    && make install

# 安装 jemalloc
RUN cd /usr/local/src && tar -zxvf jemalloc-4.5.0.tar.gz && cd jemalloc-4.5.0 \
    && ./autogen.sh \
    && ./configure --with-jemalloc-prefix=je_ \
    && make -j 4

# 安装 swoole 扩展
RUN cd /usr/local/src && tar -zxvf swoole-src-1.9.13.tar.gz && cd swoole-src-1.9.13 && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config --enable-async-redis --with-jemalloc-dir=/usr/local/src/jemalloc-4.5.0 \
    && make \
    && make install

# 配置 php.ini
RUN echo "extension=redis.so" >> /usr/local/php/etc/php.ini \
    && echo "extension=inotify.so" >> /usr/local/php/etc/php.ini \
    && echo "extension=swoole.so" >> /usr/local/php/etc/php.ini \
    && sed -i "s/;error_log = php_errors\.log/error_log = \/data\/phplogs\/error.log/" /usr/local/php/etc/php.ini

# 安装 ssh 服务
RUN yum install -y openssh-server passwd \
    && echo 'root'|passwd root --stdin \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key

# 安装 composer
RUN cd /usr/local/src && curl -sS https://getcomposer.org/installer | php \
    && composer config -g repo.packagist composer https://packagist.phpcomposer.com

# 安装 SwooleDistributed 扩展
RUN cd /data/wwwroot && composer install

# 启动 web 环境
CMD /etc/init.d/php-fpm start \
    && /etc/init.d/nginx start \
    && /etc/init.d/redis start \
    && /usr/sbin/sshd \
    && /bin/bash


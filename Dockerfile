FROM shmilyin/php-7.1-cli
MAINTAINER shmilyin <351140724@qq.com>
# 构建swoole环境，在这里安装了php,swoole,composer
RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    vim \
    libssl-dev \
    unzip \
    wget \
    git \
    make \
    supervisor \
    --no-install-recommends \
    && docker-php-ext-install zip opcache bcmath pdo_mysql \
    && cd /home && rm -rf temp && mkdir temp && cd temp \
    && wget https://github.com/swoole/swoole-src/archive/v4.0.1.tar.gz \
    https://github.com/redis/hiredis/archive/v0.13.3.tar.gz \
    https://github.com/phpredis/phpredis/archive/3.1.6.tar.gz \
    && tar -xzvf 3.1.6.tar.gz \
    && tar -xzvf v0.13.3.tar.gz \
    && tar -xzvf v4.0.1.tar.gz \
    && cd /home/temp/hiredis-0.13.3 \
    && make -j && make install && ldconfig \
    && cd /home/temp/swoole-src-4.0.1 \
    && phpize && ./configure --enable-async-redis --enable-openssl && make \
    && make install \
    && pecl install inotify \
    && pecl install ds \
    && pecl install igbinary \
    && cd /home/temp/phpredis-3.1.6 \
    && phpize \
    && ./configure --enable-redis-igbinary \
    && make &&  make install \
    && cd /home/temp \
    && php -r"copy('https://getcomposer.org/installer','composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && rm -rf /home/temp \
    && cd /usr/local/etc/php/conf.d/ \
    && echo extension=igbinary.so>igbinary.ini \
    && echo extension=redis.so>redis.ini \
    && echo extension=inotify.so>inotify.ini \
    && echo extension=swoole.so>swoole.ini \
    && echo extension=ds.so>ds.ini \
    && composer config -g repo.packagist composer https://packagist.phpcomposer.com \
    && mkdir -p /var/log/supervisor \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY ./config/* /usr/local/etc/php/conf.d/

# 设置容器时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir /apps

COPY composer.json /apps/composer.json

RUN cd /apps && composer install && php vendor/tmtbe/swooledistributed/src/Install.php -y

COPY docker-sd-entrypoint /usr/local/bin/

COPY swoole /usr/local/bin/ && chmod +x /usr/local/bin/swoole

ENTRYPOINT ["docker-sd-entrypoint"]

CMD ["php","/apps/bin/start_swoole_server.php","start"]
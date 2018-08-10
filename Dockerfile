FROM shmilyin/php-7.1-sd:base
MAINTAINER shmilyin <351140724@qq.com>

RUN mkdir /apps

COPY composer.json /apps/composer.json

RUN cd /apps && composer install && php vendor/tmtbe/swooledistributed/src/Install.php -y

COPY docker-sd-entrypoint swoole /usr/local/bin/

ENTRYPOINT ["docker-sd-entrypoint"]

CMD ["php","/apps/bin/start_swoole_server.php","start"]
FROM shmilyin/php-7.1-sd:base-sd
MAINTAINER shmilyin <351140724@qq.com>

COPY docker-sd-entrypoint swoole /usr/local/bin/

ENTRYPOINT ["docker-sd-entrypoint"]

CMD ["php","/apps/bin/start_swoole_server.php","start"]
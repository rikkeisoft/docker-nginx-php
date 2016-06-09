#!/bin/bash
set -e

if [ -f "/var/run/php-fpm.pid" ]; then
  local pid=`cat /var/run/php-fpm.pid`
  if [ ! -z ${pid} ]; then
    echo "PHP-FPM is running. Killing pid ${pid}"
    kill -QUIT ${pid}
  fi
fi

if [ -f "/var/run/nginx.pid" ]; then
  local pid=`cat /var/run/nginx.pid`
  if [ ! -z ${pid} ]; then
    echo "Nginx is running. Killing pid ${pid}"
    kill -QUIT ${pid}
  fi
fi

chown -R nginx:nginx /var/www/html

php-fpm -g /var/run/php-fpm.pid
exec "nginx" -g "daemon off;"

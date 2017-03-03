#!/bin/bash
set -e

if [ -f "/var/run/php-fpm.pid" ]; then
  fpm_pid=`cat /var/run/php-fpm.pid`
  if [ ! -z ${fpm_pid} ]; then
    if (ps -p $fpm_pid > /dev/null); then
      echo "PHP-FPM is running. Killing pid ${fpm_pid}"
      kill -QUIT ${fpm_pid}
      echo "" > /var/run/php-fpm.pid
    fi
  fi
fi

if [ -f "/var/run/nginx.pid" ]; then
  nginx_pid=`cat /var/run/nginx.pid`
  if [ ! -z ${nginx_pid} ]; then
    if (ps -p $nginx_pid > /dev/null); then
      echo "Nginx is running. Killing pid ${nginx_pid}"
      kill -QUIT ${nginx_pid}
      echo "" > /var/run/nginx.pid
    fi
  fi
fi

chown -R nginx:nginx /var/www/html

php-fpm -g /var/run/php-fpm.pid
exec "nginx" -g "daemon off;"

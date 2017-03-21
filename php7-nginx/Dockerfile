FROM alpine:3.4

MAINTAINER Huy Nguyen Quang <huynq@rikkeisoft.com>

# NGINX ENV
ENV NGINX_USER nginx
ENV NGINX_VERSION 1.11.10
ENV NGINX_GPG_KEYS B0F4253373F8F6F510D42178520A9993A1C052F8
ENV NGINX_CONFIG "\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_perl_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    "

# PHP-FPM ENV
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx
ENV PHP_GPG_KEYS A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E
ENV PHP_VERSION 7.1.3
ENV PHP_FILENAME php-$PHP_VERSION.tar.xz
ENV PHP_SHA256 e4887c2634778e37fd962fbdf5c4a7d32cd708482fe07b448804625570cb0bb0
ENV PHPIZE_DEPS "\
    autoconf \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkgconf \
    re2c \
    "

RUN echo "http://dl-2.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-3.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-5.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk add --no-cache  --update --virtual .persistent-deps \
        ca-certificates \
        curl \
        tar \
        xz

COPY conf/sysctl.conf /etc/sysctl.conf

# Install Nginx 1.11.10
RUN \
    addgroup -S $NGINX_USER \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G $NGINX_USER $NGINX_USER \
    && apk --no-cache --update add shadow \
    && usermod -u 1000 $NGINX_USER \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        curl \
        gnupg \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        perl-dev \
    && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
    && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$NGINX_GPG_KEYS" \
    && gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
    && rm -r "$GNUPGHOME" nginx.tar.gz.asc \
    && mkdir -p /usr/src \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && rm nginx.tar.gz \
    && cd /usr/src/nginx-$NGINX_VERSION \
    && ./configure $NGINX_CONFIG --with-debug \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && mv objs/nginx objs/nginx-debug \
    && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
    && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
    && mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
    && mv objs/ngx_http_perl_module.so objs/ngx_http_perl_module-debug.so \
    && mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
    && ./configure $NGINX_CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && rm -rf /etc/nginx/html/ \
    && mkdir /etc/nginx/conf.d/ \
    && mkdir -p /usr/share/nginx/html/ \
    && install -m644 html/index.html /usr/share/nginx/html/ \
    && install -m644 html/50x.html /usr/share/nginx/html/ \
    && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
    && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
    && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
    && install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
    && install -m755 objs/ngx_http_perl_module-debug.so /usr/lib/nginx/modules/ngx_http_perl_module-debug.so \
    && install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
    && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
    && strip /usr/sbin/nginx* \
    && strip /usr/lib/nginx/modules/*.so \
    && rm -rf /usr/src/nginx-$NGINX_VERSION \
    \
    # Bring in gettext so we can get `envsubst`, then throw
    # the rest away. To do this, we need to install `gettext`
    # then move `envsubst` out of the way so `gettext` can
    # be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .nginx-rundeps $runDeps \
    && apk del .build-deps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
    \
    && apk add --no-cache \
        procps \
        gettext \
        bash \
        gawk \
        sed \
        grep \
        bc \
        coreutils \
        git \
        libmcrypt-dev \
        unzip \
        zlib-dev \
    \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Copy Nginx configs
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Install PHP-FPM 7.1.3
RUN set -xe \
    && apk add --no-cache --virtual .fetch-deps \
        gnupg \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && curl -fSL "https://secure.php.net/get/$PHP_FILENAME/from/this/mirror" -o php.tar.xz \
    && echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c - \
    && curl -fSL "https://secure.php.net/get/$PHP_FILENAME.asc/from/this/mirror" -o php.tar.xz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && for key in $PHP_GPG_KEYS; do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done \
    && gpg --batch --verify php.tar.xz.asc php.tar.xz \
    && rm -r "$GNUPGHOME" \
    && apk del .fetch-deps

COPY bin/docker-php-source /usr/local/bin/

RUN set -xe \
    && mkdir -p $PHP_INI_DIR/conf.d \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        curl-dev \
        gnupg \
        libedit-dev \
        libxml2-dev \
        openssl-dev \
        sqlite-dev \
    && chmod +x /usr/local/bin/docker-php-source \
    && sync \
    && docker-php-source extract \
    && cd /usr/src/php \
    && ./configure \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        \
        --disable-cgi \
        \
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
        --enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
        --enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
        --enable-mysqlnd \
        --with-curl \
        --with-libedit \
        --with-openssl \
        --with-zlib \
        \
        $PHP_EXTRA_CONFIGURE_ARGS \
    && make -j"$(getconf _NPROCESSORS_ONLN)" \
    && make install \
    && { find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; } \
    && make clean \
    && docker-php-source delete \
    \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .php-rundeps $runDeps \
    \
    && apk del .build-deps

# Configure PHP-FPM
RUN set -ex \
    && mkdir -p /var/log/php-fpm/ \
    && cd /usr/local/etc \
    && if [ -d php-fpm.d ]; then \
        # for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
        sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
        cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
    else \
        # PHP 5.x don't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
        mkdir php-fpm.d; \
        cp php-fpm.conf.default php-fpm.d/www.conf; \
        { \
            echo '[global]'; \
            echo 'include=etc/php-fpm.d/*.conf'; \
        } | tee php-fpm.conf; \
    fi \
    && { \
        echo '[global]'; \
        echo 'error_log = /var/log/php-fpm/error_log'; \
        echo; \
        echo '[www]'; \
        echo '; if we send this to /proc/self/fd/1, it never appears'; \
        echo 'access.log = /var/log/php-fpm/access_log'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
    } | tee php-fpm.d/docker.conf \
    && { \
        echo '[global]'; \
        echo 'daemonize = yes'; \
        echo; \
        echo '[www]'; \
        echo 'listen = [::]:9000'; \
    } | tee php-fpm.d/zz-docker.conf

# Copy php extension ultilities
COPY bin/docker-php-ext-* /usr/local/bin/

# Install php extensions
RUN chmod +x /usr/local/bin/docker-php-* \
    && sync \
    && docker-php-ext-install pdo pdo_mysql mcrypt iconv mbstring zip

# Workdir
WORKDIR /var/www/html

# PHP Default Script
COPY html/index.php /var/www/html/

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/bin/composer

# Export 80 for http & 443 for https
EXPOSE 80 443

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

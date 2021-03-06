FROM php:apache

RUN curl -OL https://deb.nodesource.com/setup_6.x \
    && bash setup_6.x

RUN apt-get update && apt-get install -y \
    git \
    libzip-dev \
    multitail \
    htop \
    libmemcached-dev \
    libpq-dev \
    nodejs \
    libnotify-bin \
    php-amqplib \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev

RUN a2enmod rewrite headers

RUN docker-php-ext-install \
    zip \
    mysqli \
    pdo_mysql

RUN curl -OLk http://xdebug.org/files/xdebug-2.5.0.tgz \
    && tar -zxf xdebug-2.5.0.tgz \
    && rm -rf xdebug-2.5.0.tgz \
    && cd xdebug-2.5.0 \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable xdebug

RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/v3.0.0.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

RUN echo "[xdebug]" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_enable=true" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host=10.254.254.254" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "remote_enable=true" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "remote_host=10.254.254.254" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN git clone https://github.com/sass/libsass.git \
    && cd libsass \
    && git checkout 3.4.3 \
    && ./script/bootstrap \
    && make \
    && cd sassc \
    && make install

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
        --install-dir=/usr/local/bin \
        --filename=composer \
    && php -r "unlink('composer-setup.php');"

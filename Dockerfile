FROM php:apache

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8
ENV TERM xterm
ENV WWW_ROOT="/var/www"

MAINTAINER Sigmapix <sigmapix@gmail.com>

RUN echo "nameserver 8.8.8.8" | tee /etc/resolv.conf > /dev/null \
    && sed -e 's/main/main contrib/g' -i /etc/apt/sources.list \
    && echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list \
    && apt-get clean \
    && apt-get update -y \
    && apt-get install -y --fix-missing \
        wget \
        curl \
        cron \
        sudo \
        git-core \
        vim \
        ncurses-term \
        zlib1g-dev \
        libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxml2-dev \
        xfonts-base \
        xfonts-75dpi \
        fonts-liberation \
        logrotate \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install -j$(nproc) \
	    mysqli \
        mbstring \
        mcrypt \
        pdo \
        pdo_mysql \
    	iconv \
        zip \
        intl \
        sockets \
        soap \
        opcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN pecl install channel://pecl.php.net/apcu_bc-1.0.3
RUN docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini
RUN docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

RUN apt-get install -y xz-utils x11-utils wget

RUN docker-php-ext-install -j$(nproc) bcmath
RUN wget https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -P /tmp/ && \
    tar xf /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -C /tmp/ && \
        cp /tmp/wkhtmltox/bin/wkhtmltopdf /usr/local/bin/

ADD update-exim4.conf /etc/exim4/update-exim4.conf.conf
RUN /usr/sbin/update-exim4.conf

# PhpUnit ( phpunit --exclude-group ignore -v --debug -c app src/ )
RUN wget https://phar.phpunit.de/phpunit.phar -O /usr/local/bin/phpunit && chmod +x /usr/local/bin/phpunit

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

RUN a2enmod rewrite
RUN a2enmod remoteip

CMD ["/entrypoint.sh"]

EXPOSE 80
EXPOSE 443

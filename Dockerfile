#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM debian:12

# To enable latest Apache image on buster:
# RUN echo deb http://deb.debian.org/debian buster-backports main | tee /etc/apt/sources.list.d/buster-backports.list

# persistent / runtime deps
ENV PHPIZE_DEPS \
		autoconf \
		file \
		g++ \
		gcc \
		libc-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libmagickcore-dev \
        libmagickwand-dev \
        zlib1g-dev \
        libzip-dev \
#        libsodium-dev \
		make \
		pkg-config \
        gpg-agent \
        imagemagick \
		re2c
RUN apt-get update && apt-get install -y \
		$PHPIZE_DEPS \
		ca-certificates \
		curl \
		libedit2 \
		libsqlite3-0 \
		libxml2 \
		xz-utils \
        vim \
        gpg \
        dirmngr \
        locales \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

# Configure locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales 

##<autogenerated>##
RUN apt-get update && apt-get install -y apache2 --no-install-recommends && rm -rf /var/lib/apt/lists/*
# Line with backport apache
#RUN apt-get update && apt-get install -y -t buster-backports apache2 --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

RUN set -ex \
	\
# generically convert lines like
#   export APACHE_RUN_USER=www-data
# into
#   : ${APACHE_RUN_USER:=www-data}
#   export APACHE_RUN_USER
# so that they can be overridden at runtime ("-e APACHE_RUN_USER=...")
	&& sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' "$APACHE_ENVVARS" \
	\
# setup directories and permissions
	&& . "$APACHE_ENVVARS" \
	&& for dir in \
		"$APACHE_LOCK_DIR" \
		"$APACHE_RUN_DIR" \
		"$APACHE_LOG_DIR" \
		/var/www/html \
	; do \
		rm -rvf "$dir" \
		&& mkdir -p "$dir" \
		&& chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
	done

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork && a2dismod status

# logs should go to stdout / stderr
RUN set -ex \
	&& . "$APACHE_ENVVARS" \
	&& ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN { \
		echo '<FilesMatch \.php$>'; \
		echo '\tSetHandler application/x-httpd-php'; \
		echo '</FilesMatch>'; \
		echo; \
		echo 'DirectoryIndex disabled'; \
		echo 'DirectoryIndex index.php index.html'; \
		echo; \
		echo '<Directory /var/www/>'; \
		echo '\tOptions -Indexes'; \
		echo '\tAllowOverride All'; \
		echo '</Directory>'; \
	} | tee "$APACHE_CONFDIR/conf-available/docker-php.conf" \
	&& a2enconf docker-php

ENV PHP_EXTRA_BUILD_DEPS apache2-dev
ENV PHP_EXTRA_CONFIGURE_ARGS="--with-apxs2 --with-kerberos --with-pear"
##</autogenerated>##

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# Adds GNU HASH segments to generated executables (this is used if present, and is much faster than sysv hash; in this configuration, sysv hash is also generated)
# https://github.com/docker-library/php/issues/272
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

# PHP 8.2 (for GPG KEY watch out "using key ... " notice in error message) / changes with minor versions
ENV GPG_KEYS "1198C0117593497A5EC5C199286AF1F9897469DC 39B641343D8C104B2B146DC3F9C39DC0B9698544 E60913E4DF209907D8E30D96659A97C9CF2A795A"
ENV PHP_VERSION 8.2.12
ENV PHP_URL="https://www.php.net/distributions/php-${PHP_VERSION}.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-${PHP_VERSION}.tar.xz.asc"
ENV PHP_SHA256="e1526e400bce9f9f9f774603cfac6b72b5e8f89fa66971ebc3cc4e5964083132" PHP_MD5=""

RUN set -xe; \
	\
	fetchDeps=' \
		wget \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	wget -O php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_MD5" ]; then \
		echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
	fi; \
	\
	if [ -n "$PHP_ASC_URL" ]; then \
		wget -O php.tar.xz.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
		done; \
		gpg --batch --verify php.tar.xz.asc php.tar.xz; \
		rm -r "$GNUPGHOME"; \
	fi; \
	\
	apt-get purge -y --auto-remove $fetchDeps

COPY docker-php-* /usr/local/bin/

RUN set -xe \
	&& buildDeps=" \
		$PHP_EXTRA_BUILD_DEPS \
		libcurl4-openssl-dev \
		libedit-dev \
		libsqlite3-dev \
		libssl-dev \
		libzip-dev \
		libicu-dev \
		libkrb5-dev \
		libonig-dev \
		libxml2-dev \
	" \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
        LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/icu/lib \
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
		--enable-exif \
        --enable-intl \
		\
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		\
		$PHP_EXTRA_CONFIGURE_ARGS \
	&& make -j "$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& make clean \
	&& docker-php-source delete \
	\
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]
##<autogenerated>##
##Additional:
RUN apt-get update && apt-get install -y libc-client-dev libkrb5-dev libonig-dev libzip-dev libmagickwand-dev libmagickcore-dev imagemagick --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure imap --with-imap-ssl --with-kerberos
RUN docker-php-ext-install -j$(nproc) gd imap zip mysqli pdo_mysql iconv 

# Fix mcrypt for 8.1 PHP before 1.0.5 comes out
RUN pecl channel-update pecl.php.net && pecl install mcrypt && docker-php-ext-enable mcrypt
#COPY mcrypt-1.0.4.tgz /usr/src/php/ext/
#RUN    cd /usr/src/php/ext \
#    && tar xzf mcrypt-1.0.4.tgz \
#    && mv mcrypt-1.0.4 mcrypt \
#    && docker-php-ext-configure mcrypt \
#    && docker-php-ext-install -j$(nproc) mcrypt \
#    && docker-php-ext-enable mcrypt
# End of fix
#RUN pecl install intl && docker-php-ext-enable intl
RUN pecl install imagick && docker-php-ext-enable imagick
RUN pecl install xdebug
# libsodium needs 1.0.9 but had 1.0.0 only. So not using it at the moment
#RUN pecl install libsodium-2.0.21 && docker-php-ext-enable libsodium

# Install PHP composer
RUN cd /usr/local/bin \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Configure Apache as needed
RUN a2enmod proxy proxy_http proxy_ajp rewrite deflate substitute headers \
    proxy_balancer proxy_connect proxy_html xml2enc authnz_ldap authz_host \
    remoteip expires \
    && apache2ctl -v

RUN rm -f /etc/apache2/conf-enabled/security.conf /etc/apache2/conf-available/security.conf
COPY etc/conf/ /etc/apache2/conf-enabled/
COPY apache2-foreground /usr/local/bin/

ADD etc/php/ /usr/local/etc/php/conf.d/

RUN apache2ctl -v
RUN php -v
RUN php -m
WORKDIR /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]

##</autogenerated>##

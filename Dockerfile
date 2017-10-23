# FROM arm64v8/php:latest
FROM amd64/php:apache-jessie

# COPY tmp/qemu-aarch64-static /usr/bin/qemu-aarch64-static   
  
# ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade \
    && apt-get dist-upgrade -y

RUN apt-get install apt-transport-https lsb-release ca-certificates wget -y \
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update

RUN apt-get install libcurl4-gnutls-dev php7.1-curl php7.1-json php7.1-mcrypt php7.1-mysql git-core libmcrypt-dev -y

# Install pecl dependencies
# RUN pear channel-discover pear.swiftmailer.org  #email_fix see https://github.com/carboncoop/emoncms/edit/NEF_SRH/Lib/email.php
# RUN pecl install swift/swift dio-0.0.9 redis #email_fix see https://github.com/carboncoop/emoncms/edit/NEF_SRH/Lib/email.php
RUN pecl install dio redis

RUN docker-php-ext-install -j$(nproc) mysqli curl json mcrypt gettext
RUN docker-php-ext-enable redis

RUN mkdir log4php
RUN cd log4php
RUN wget http://www-eu.apache.org/dist/logging/log4php/2.3.0/Apache_log4php-2.3.0.tgz
RUN wget https://raw.githubusercontent.com/spanghf37/emoncms/master/channel.xml
RUN pear channel-add channel.xml
RUN pear install Apache_log4php-2.3.0.tgz

# Enable modrewrite for Apache2
RUN a2enmod rewrite

# Add custom PHP config
COPY config/php.ini /usr/local/etc/php/

# Clone in master Emoncms repo & modules - overwritten in development with local FS files
WORKDIR /var/www/html
RUN git clone https://github.com/emoncms/emoncms.git
WORKDIR /var/www/html/emoncms/Modules
RUN git clone https://github.com/emoncms/dashboard.git
WORKDIR /var/www/html/emoncms/Modules
RUN git clone https://github.com/emoncms/graph.git
RUN chown -R www-data:root /var/www/html/emoncms

# Copy in settings from defaults
# WORKDIR /var/www/html/emoncms/
# RUN cp default.settings.php settings.php
COPY docker.settings.php /var/www/html/emoncms/settings.php

# Create folders & set permissions for feed-engine data folders (mounted as docker volumes in docker-compose)
RUN mkdir /var/lib/phpfiwa \
    && mkdir /var/lib/phpfina \
    && mkdir /var/lib/phptimeseries \ 
    && chown -R www-data:root /var/lib/phpfiwa \
    && chown -R www-data:root /var/lib/phpfina \
    && chown -R www-data:root /var/lib/phptimeseries

# Create Emoncms logfile
RUN touch /var/log/emoncms.log \
    && chmod 666 /var/log/emoncms.log

# Install composer in /usr/lib folder
WORKDIR /usr/lib
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');"

# Install swiftmailer
RUN php /usr/lib/composer.phar require swiftmailer/swiftmailer @stable

#email_fix see https://github.com/carboncoop/emoncms/edit/NEF_SRH/Lib/email.php
RUN rm /var/www/html/emoncms/Lib/email.php
WORKDIR /var/www/html/emoncms/Lib
RUN wget https://raw.githubusercontent.com/spanghf37/emoncms/amd64/email_fix/email.php

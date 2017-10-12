# FROM arm64v8/php:latest
FROM amd64/php:latest

# COPY tmp/qemu-aarch64-static /usr/bin/qemu-aarch64-static   
  
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

RUN apt-get install apache2 libcurl4-gnutls-dev mysql-server mysql-client git-core redis-server build-essential ufw ntp libmcrypt-dev -y
RUN apt-get install wget -y

# Install pecl dependencies
RUN pear channel-discover pear.swiftmailer.org
RUN pecl install swift/swift dio-0.0.9 redis

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

# Copy in settings from defaults
# WORKDIR /var/www/html/emoncms/
# RUN cp default.settings.php settings.php
COPY docker.settings.php /var/www/html/settings.php

# Create folders & set permissions for feed-engine data folders (mounted as docker volumes in docker-compose)
RUN mkdir /var/lib/phpfiwa
RUN mkdir /var/lib/phpfina
RUN mkdir /var/lib/phptimeseries
RUN chown www-data:root /var/lib/phpfiwa
RUN chown www-data:root /var/lib/phpfina
RUN chown www-data:root /var/lib/phptimeseries

# Create Emoncms logfile
RUN touch /var/log/emoncms.log
RUN chmod 666 /var/log/emoncms.log

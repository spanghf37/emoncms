FROM arm64v8/debian:latest

COPY tmp/qemu-aarch64-static /usr/bin/qemu-aarch64-static   
  
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
#RUN apt-get -yq install supervisor apache2 mysql-server mysql-client php libapache2-mod-php php-mysql php-curl php-pear \
#    php-dev php-mcrypt php-json git-core redis-server build-essential ufw ntp pwgen

RUN apt-get install apache2 mysql-server mysql-client php libapache2-mod-php php-mysql php-curl php-pear php-dev php-mcrypt php-json git-core redis-server build-essential ufw ntp -y
RUN apt-get install wget

# Install pecl dependencies
RUN pear channel-discover pear.swiftmailer.org
RUN pecl install swift/swift dio-0.0.9 redis

# RUN pear channel-discover pear.apache.org/log4php
# RUN pear install log4php/Apache_log4php

RUN mkdir log4php
RUN cd log4php
# RUN wget http://www-eu.apache.org/dist/logging/log4php/2.3.0/apache-log4php-2.3.0-src.tar.gz
# RUN tar xzvf apache-log4php-2.3.0-src.tar.gz
RUN wget http://www-eu.apache.org/dist/logging/log4php/2.3.0/Apache_log4php-2.3.0.tgz
RUN pear install --offline Apache_log4php-2.3.0.tgz

# Add pecl modules to php7 configuration
RUN sh -c 'echo "extension=dio.so" > /etc/php/7.0/apache2/conf.d/20-dio.ini'
RUN sh -c 'echo "extension=dio.so" > /etc/php/7.0/cli/conf.d/20-dio.ini'
RUN sh -c 'echo "extension=redis.so" > /etc/php/7.0/apache2/conf.d/20-redis.ini'
RUN sh -c 'echo "extension=redis.so" > /etc/php/7.0/cli/conf.d/20-redis.ini'

# Enable modrewrite for Apache2
RUN a2enmod rewrite

# AllowOverride for / and /var/www
RUN sed -i '/<Directory \/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Set a server name for Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add db setup script
ADD run.sh /run.sh
ADD db.sh /db.sh
RUN chmod 755 /*.sh

# Add MySQL config
ADD my.cnf /etc/mysql/conf.d/my.cnf

# Add supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create required data repositories for emoncms feed engine
RUN mkdir /var/lib/phpfiwa
RUN mkdir /var/lib/phpfina
RUN mkdir /var/lib/phptimeseries
RUN mkdir /var/lib/timestore

RUN touch /var/www/html/emoncms.log
RUN chmod 666 /var/www/html/emoncms.log

# Expose them as volumes for mounting by host
VOLUME ["/etc/mysql", "/var/lib/mysql", "/var/lib/phpfiwa", "/var/lib/phpfina", "/var/lib/phptimeseries", "/var/www/html"]

EXPOSE 80 3306

WORKDIR /var/www/emoncms
CMD ["/run.sh"]

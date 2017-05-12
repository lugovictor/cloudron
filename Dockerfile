FROM cloudron/base:0.9.0
MAINTAINER Afian AB <info@filerun.com>

RUN mkdir -p /app/html

# Install filerun
RUN curl -o /filerun.zip -L https://www.filerun.com/download-latest

ADD config.php /app/
ADD autoconfig.template /app/
ADD clogo.png /app/
ADD DB.php /app/

# configure apache
RUN rm /etc/apache2/sites-enabled/*
RUN sed -e 's,^ErrorLog.*,ErrorLog "|/bin/cat",' -i /etc/apache2/apache2.conf
RUN sed -e "s,MaxSpareServers[^:].*,MaxSpareServers 5," -i /etc/apache2/mods-available/mpm_prefork.conf

RUN a2disconf other-vhosts-access-log
ADD apache2-filerun.conf /etc/apache2/sites-available/filerun.conf
RUN ln -sf /etc/apache2/sites-available/filerun.conf /etc/apache2/sites-enabled/filerun.conf
RUN echo "Listen 8000" > /etc/apache2/ports.conf

# Install Ioncube
RUN curl -O http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
 && tar xvfz ioncube_loaders_lin_x86-64.tar.gz \
 && PHP_EXT_DIR=/usr/lib/php/20151012 \
 && cp "ioncube/ioncube_loader_lin_7.0.so" $PHP_EXT_DIR \
 && echo "zend_extension=ioncube_loader_lin_7.0.so" >> /etc/php/7.0/apache2/conf.d/00_ioncube_loader_lin_7.0.ini \
 && rm -rf ioncube ioncube_loaders_lin_x86-64.tar.gz

# set recommended PHP.ini settings
# see http://docs.filerun.com/php_configuration
ADD filerun-optimization.ini /etc/php/7.0/apache2/conf.d/filerun-optimization.ini

RUN apt-get update && apt-get install -y ghostscript libgs-dev ffmpeg && rm -r /var/cache/apt /var/lib/apt/lists


ADD start.sh /app/
ADD db.sql /app/
RUN chown -R www-data.www-data /app/html

RUN chmod +x /app/start.sh
CMD [ "/app/start.sh" ]

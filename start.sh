#!/bin/bash
set -eux
if [ ! -e /app/data/html/index.php ];  then
	mkdir -p /app/data/html
	mkdir /app/data/php-temp
	mkdir -p /app/data/user-files/superuser
	unzip /filerun.zip -d /app/data/html
	cp /app/config.php /app/data/html/customizables/config.php
	cp /app/clogo.png /app/data/user-files/superuser/Welcome.png
	rm /app/data/html/system/classes/vendor/FileRun/Utils/DB.php
	cp /app/DB.php /app/data/html/system/classes/vendor/FileRun/Utils/DB.php
	chown -R www-data:www-data /app/data
	mysql --user=${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} ${MYSQL_DATABASE} < /app/db.sql


fi	

#needs to run on every start as the connection info might change
sed -e "s/##MYSQL_DATABASE/${MYSQL_DATABASE}/" \
    -e "s/##MYSQL_USERNAME/${MYSQL_USERNAME}/" \
    -e "s/##MYSQL_PASSWORD/${MYSQL_PASSWORD}/" \
    -e "s/##MYSQL_HOST/${MYSQL_HOST}:${MYSQL_PORT}/" \
    /app/autoconfig.template > /app/data/html/system/data/autoconfig.php # sed -i seems to destroy symlink


# start
APACHE_CONFDIR="" source /etc/apache2/envvars
rm -f "${APACHE_PID_FILE}"
exec /usr/sbin/apache2 -DFOREGROUND

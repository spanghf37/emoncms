#!/bin/bash 
#install emoncms
INDEX="/var/www/html/settings.php"
if [[ ! -d $INDEX ]]; then
  rm -rf /var/www/html
  git clone https://github.com/emoncms/emoncms.git /var/www/html
  git clone https://github.com/emoncms/event.git /var/www/html/Modules/event
  git clone https://github.com/emoncms/app.git /var/www/html/Modules/app
  git clone https://github.com/emoncms/usefulscripts.git /usr/local/bin/emoncms_usefulscripts
  git clone https://github.com/emoncms/dashboard.git /var/www/html/Modules/dashboard
  git clone https://github.com/emoncms/device.git /var/www/html/Modules/device
fi

touch /var/www/html/emoncms.log
chmod 666 /var/www/html/emoncms.log

# Check that user has supplied a MYSQL_PASSWORD
if [[ -z $MYSQL_PASSWORD ]]; then 
  # Uncomment the line below to use a random password
  # MYSQL_PASSWORD="$(pwgen -s 12 1)"
  echo 'Ensure that you have supplied a password using the -e MYSQL_PASSWORD="mypass"'
  exit 1;
fi

# Initialize MySQL if it not initialized yet
MYSQL_HOME="/var/lib/mysql"
if [[ ! -d $MYSQL_HOME/mysql ]]; then
  echo "=> Installing MySQL ..."
  mysql_install_db # > /dev/null 2>&1
else
  echo "=> Using an existing volume of MySQL"
fi

# Run db scripts only if there's no existing emoncms database
EMON_HOME="/var/lib/mysql/emoncms"
if [[ ! -d $EMON_HOME ]]; then
  /db.sh
fi

# Update the settings file for emoncms
EMON_DIR="/var/www/html"
SETPHP="$EMON_DIR/settings.php"
if [[ ! -d $SETPHP ]]; then
  cp "$EMON_DIR/default.settings.php" "$EMON_DIR/settings.php"
  sed -i "s/_DB_USER_/emoncms/" "$EMON_DIR/settings.php"
  sed -i "s/_DB_PASSWORD_/$MYSQL_PASSWORD/" "$EMON_DIR/settings.php"
  sed -i "s/localhost/127.0.0.1/" "$EMON_DIR/settings.php"
fi

echo "==========================================================="
echo "The username and password for the emoncms user is:"
echo ""
echo "   username: emoncms"
echo "   password: $MYSQL_PASSWORD"
echo ""
echo "==========================================================="

# Setup Apache
source /etc/apache2/envvars

# Use supervisord to start all processes
supervisord -c /etc/supervisor/conf.d/supervisord.conf

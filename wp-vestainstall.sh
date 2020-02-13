#!/bin/bash
# This script installs Vesta, WP-CLI, and WordPress from Command Line.

#Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

sudo apt install -y nano curl
curl -O http://vestacp.com/pub/vst-install.sh
bash vst-install.sh --nginx yes --phpfpm yes --apache no --named yes --remi yes --vsftpd yes --proftpd no --iptables yes --fail2ban yes --quota no --exim yes --dovecot yes --spamassassin yes --clamav yes --softaculous no --mysql yes --postgresql no --hostname panel.server.com --email luismi.delgado@gmail.com --password ju%qRYEe0u0P

## Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

su - admin -c 'cd ~ && wget https://github.com/wp-cli/wp-cli/raw/master/utils/wp-completion.bash && echo "source /home/$USER/wp-completion.bash" >> ~/.bashrc"'


#Este script está muy completo:
#https://gist.githubusercontent.com/mighildotcom/7205442783534792a606df39629e22d3/raw/a02564e5eb9931da31e3f4988717b6119a82ea6e/vesta-wp.sh
read -p "Username : " user
read -p "Domain   : " domain

#------------ ADD DOMAIN IN VESTACP -----------------
/usr/local/vesta/bin/v-add-domain $user $domain

# bash generate random 32 character alphanumeric string (upper and lowercase) an                                                                             d
db_user=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)
db_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

#------------ ADD DATABASE IN VESTACP -----------------
/usr/local/vesta/bin/v-add-database $user $db_user $db_user $db_pass

username=${user}_${db_user}
echo "DB Username : $username"
echo "DB Password : $db_pass"

#mkdir testdir
#cd testdir
#wp core download --locale=es_ES
#wp config create --dbname=wptest --dbuser=myuser --dbpass=mypass
#wp db create
#wp core install --url=midominio.com --title="Mi nueva web con WordPress" --admin_user=usuario --admin_password=contraseña --admin_email=email@email.com

##Idea para añadir wp-cli en la instalación de Wordpress
#https://github.com/lukapaunovic/create_wp/blob/master/create_wp.sh
cd /home/$user/web/$domain/public_html/
clear
echo "============================================"
echo "WordPress Install Script"
echo "============================================"
echo "============================================"
echo "A robot is now installing WordPress for you."
echo "============================================"
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
#modifica la carpeta de instalacion wordpress
cd wordpress
#copy file to parent dir
cp -rf . ..
#move back to parent dir
cd ..
#remove files from wordpress folder
rm -R wordpress
#create wp config
cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$username/g" wp-config.php
perl -pi -e "s/username_here/$username/g" wp-config.php
perl -pi -e "s/password_here/$db_pass/g" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 775 wp-content/uploads
echo "Cleaning..."
#remove zip file
rm latest.tar.gz
#remove bash script
echo "========================="
echo "Installation is complete."
echo "========================="

#!/bin/bash
# This script installs Vesta, WP-CLI, and WordPress from Command Line.

# Prevents doing this from other account than root
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

# Actualizamos el sistema y eliminamos paquetes innecesarios
apt-get -y update
apt-get -y upgrade
apt-get -y autoremove

#Script con todos los pasos:
#apt update && apt upgrade -y && apt install -y nano curl && curl -O http://vestacp.com/pub/vst-install.sh && bash vst-install.sh --nginx yes --phpfpm yes --apache no --named yes --remi yes --vsftpd yes --proftpd no --iptables yes --fail2ban yes --quota no --exim yes --dovecot yes --spamassassin yes --clamav yes --softaculous no --mysql yes --postgresql no --hostname server.culturavalenciana.com --email luismi.delgado@gmail.com --password ju%qRYEe0u0P --force

#&& v-add-letsencrypt-domain 'admin' $HOSTNAME '' 'yes' && v-update-host-certificate admin $HOSTNAME && echo "UPDATE_HOSTN

##Colors settings, https://gist.github.com/vratiu/9780109
#BLUE='\033[0;34m'
#GREEN='\033[0;32m'
#RED='\033[0;31m'
#YELLOW='\033[0;33m'
#NC='\033[0m' # No Color
#echo -e "\033[31m Hello World"


sudo apt install -y nano curl
curl -O http://vestacp.com/pub/vst-install.sh
bash vst-install.sh --nginx yes --phpfpm yes --apache no --named yes --remi yes --vsftpd yes --proftpd no --iptables yes --fail2ban yes --quota no --exim yes --dovecot yes --spamassassin yes --clamav yes --softaculous no --mysql yes --postgresql no --hostname server.culturavalenciana.com --email luismi.delgado@gmail.com --password ju%qRYEe0u0P --force

##Utilizamos el certificado del dominio principal para que sea el de VESTA
mv /usr/local/vesta/ssl/certificate.crt /usr/local/vesta/ssl/unusablecer.crt
mv /usr/local/vesta/ssl/certificate.key /usr/local/vesta/ssl/unusablecer.key

ln -s /home/admin/conf/web/ssl.dominio.com.crt /usr/local/vesta/ssl/certificate.crt
ln -s /home/admin/conf/web/ssl.dominio.com.key /usr/local/vesta/ssl/certificate.key

chgrp mail /usr/local/vesta/ssl/certificate.crt
chmod 660 /usr/local/vesta/ssl/certificate.crt
chmod 660 /usr/local/vesta/ssl/certificate.key

service vesta restart


echo "============================================"
echo "WordPress Install Script"
echo "============================================"
## Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

su - admin -c 'cd ~ && wget https://github.com/wp-cli/wp-cli/raw/master/utils/wp-completion.bash && echo -e "\nsource /home/$USER/wp-completion.bash" >> ~/.bashrc'


#Este script está muy completo:
#https://gist.githubusercontent.com/mighildotcom/7205442783534792a606df39629e22d3/raw/a02564e5eb9931da31e3f4988717b6119a82ea6e/vesta-wp.sh
read -p "Username : " user #Usuario que accede a Vesta (por defecto admin)
read -p "Domain   : " domain
read -p "User WP  : " usuwp

#------------ ADD DOMAIN IN VESTACP -----------------
/usr/local/vesta/bin/v-add-domain $user $domain

# bash generate random 32 character alphanumeric string (upper and lowercase)
db_user=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 5 | head -n 1)
db_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 14 | head -n 1)
db_name=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)

#------------ ADD DATABASE IN VESTACP -----------------
#v-add-database USER DATABASE DBUSER DBPASS [TYPE] [HOST] [CHARSET]
/usr/local/vesta/bin/v-add-database $user $db_name $db_user $db_pass

userdb=${user}_${db_user}
namedb=${user}_${db_name}
echo "DB Username : $usernamedb"
echo "DB Password : $db_pass"

#Esto se hace con WP-CLI
su admin
cd /home/$user/web/$domain/public_html/
wp core download --locale=es_ES --version=5.3.1 #(or 5.3) [--force] Overwrites existing files, if present.
wp config create --dbname=$namedb --dbuser=$userdb --dbpass=$db_pass
wp core install --url=midominio.com --title="Mi nueva web con WordPress" --admin_user=usuario --admin_password=contraseña --admin_email=email@email.com
#wp core install --url=huellaseo.com --title="Mi nueva web con WordPress" --admin_user=lumizito --admin_password=ustralod3 --admin_email=luismi.delgado@gmail.com
echo "Cleaning..."
rm readme.html licencia.txt license.txt index.html

#Finalización de la instalación
echo "========================="
echo "Installation is complete."
echo "========================="

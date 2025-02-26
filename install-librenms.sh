#!/bin/bash

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install required dependencies
sudo apt install -y \
    git \
    curl \
    php \
    php-cli \
    php-fpm \
    php-mbstring \
    php-xml \
    php-mysql \
    php-snmp \
    mariadb-server \
    apache2 \
    libapache2-mod-php \
    snmp \
    snmpd \
    iproute2 \
    whois \
    unzip \
    build-essential \
    python3-pip \
    git \
    jq

# Add librenms user
sudo useradd librenms -m -d /opt/librenms -r -s /bin/bash
sudo chown -R librenms:librenms /opt/librenms

# Download LibreNMS
cd /opt
sudo git clone https://github.com/librenms/librenms.git librenms

# Set permissions
cd /opt/librenms
sudo chown -R librenms:librenms /opt/librenms

# Install dependencies with composer
sudo -u librenms bash -c "curl -sS https://getcomposer.org/installer | php"
sudo -u librenms bash -c "php composer.phar install --no-dev"

# Set timezone
sudo timedatectl set-timezone Etc/UTC

# Configure MariaDB
sudo mysql_secure_installation

# Set up database for LibreNMS
sudo mysql -u root -p -e "CREATE DATABASE librenms;"
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON librenms.* TO 'librenms'@'localhost' IDENTIFIED BY 'librenmspassword';"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"

# Configure Apache
sudo cp /opt/librenms/doc/ubuntu/apache.conf /etc/apache2/sites-available/librenms.conf
sudo a2ensite librenms.conf
sudo a2enmod rewrite
sudo service apache2 restart

# Configure cron job for LibreNMS
echo "*/5 * * * * librenms /opt/librenms/poller.php 1>> /dev/null 2>&1" | sudo tee -a /etc/crontab

# Start the LibreNMS web installer
echo "LibreNMS installation complete. Please proceed with the web installer by visiting: http://<Your Server IP>/install.php"

# Done
echo "LibreNMS setup completed!"

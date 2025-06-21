#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project 'loaf-panel-installer'                                                    #
#                                                                                    #
# Copyright (C) 2018 - 2025, Vilhelm Prytz, <vilhelm@prytznet.se>                    #
#                                                                                    #
#   This program is free software: you can redistribute it and/or modify             #
#   it under the terms of the GNU General Public License as published by             #
#   the Free Software Foundation, either version 3 of the License, or                #
#   (at your option) any later version.                                              #
#                                                                                    #
#   This program is distributed in the hope that it will be useful,                  #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of                   #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                    #
#   GNU General Public License for more details.                                     #
#                                                                                    #
#   You should have received a copy of the GNU General Public License                #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.           #
#                                                                                    #
# https://github.com/LoafHost/installer/blob/master/LICENSE #
#                                                                                    #
# This script is not associated with the official Loaf Panel Project.               #
# https://github.com/LoafHost/installer                     #
#                                                                                    #
######################################################################################

# Check if script is loaded, load if not or fail otherwise.
fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  # shellcheck source=lib/lib.sh
  source /tmp/lib.sh || source <(curl -sSL "$GITHUB_BASE_URL/$GITHUB_SOURCE"/lib/lib.sh)
  ! fn_exists lib_loaded && echo "* ERROR: Could not load lib script" && exit 1
fi

# ------------------ Variables ----------------- #

PMA_VERSION="5.2.1"

# ------------ Installation functions ------------ #

install_phpmyadmin() {
  output "Installing phpMyAdmin..."

  # Install dependencies
  install_packages "unzip"

  # Download and extract phpMyAdmin
  curl -L -o /tmp/phpmyadmin.zip "https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/phpMyAdmin-${PMA_VERSION}-all-languages.zip"
  unzip -q /tmp/phpmyadmin.zip -d /var/www/
  mv /var/www/phpMyAdmin-\"${PMA_VERSION}\"-all-languages /var/www/phpmyadmin
  rm /tmp/phpmyadmin.zip

  # Create configuration file
  BLOWFISH_SECRET=$(gen_passwd 32)
  tee /var/www/phpmyadmin/config.inc.php > /dev/null <<EOF
<?php
declare(strict_types=1);

\\$cfg['blowfish_secret'] = '${BLOWFISH_SECRET}';

\\$i = 0;

\\$i++;
\\$cfg['Servers'][\\$i]['auth_type'] = 'cookie';
\\$cfg['Servers'][\\$i]['host'] = '127.0.0.1';
\\$cfg['Servers'][\\$i]['compress'] = false;
\\$cfg['Servers'][\\$i]['AllowNoPassword'] = false;

\\$cfg['UploadDir'] = '';
\\$cfg['SaveDir'] = '';
EOF

  # Secure phpMyAdmin
  chmod 644 /var/www/phpmyadmin/config.inc.php
  chown -R www-data:www-data /var/www/phpmyadmin

  # Configure nginx
  tee /etc/nginx/sites-available/phpmyadmin.conf > /dev/null <<EOF
server {
    listen 80;
    server_name pma.localhost;

    root /var/www/phpmyadmin;
    index index.php index.html index.htm;

    location / {
        try_files \\$uri \\$uri/ /index.php?\$query_string;
    }

    location ~ \\.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~ /\\.ht {
        deny all;
    }
}
EOF

  ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/
  systemctl restart nginx

  success "phpMyAdmin installed successfully!"
  output "You can access it at http://pma.localhost (you might need to add this to your hosts file)."
}

# --------------- Main functions --------------- #

perform_install() {
  install_phpmyadmin
}

# Entrypoint
main() {
  print_header
  check_distro
  check_root
  ask_continue
  perform_install
}

main

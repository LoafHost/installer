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

RM_PANEL="${RM_PANEL:-true}"
RM_WINGS="${RM_WINGS:-true}"
RM_PHPMYADMIN="${RM_PHPMYADMIN:-true}"

# ---------- Uninstallation functions ---------- #

rm_panel_files() {
  output "Removing panel files..."
  rm -rf /var/www/loaf-panel /usr/local/bin/composer
  if [ "$OS" != "centos" ]; then
    unlink /etc/nginx/sites-enabled/loaf-panel.conf
    rm -f /etc/nginx/sites-available/loaf-panel.conf
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
  else
    rm -f /etc/nginx/conf.d/loaf-panel.conf
  fi
  systemctl restart nginx
  success "Removed panel files."
}

rm_phpmyadmin_files() {
  if [ -d "/var/www/phpmyadmin" ]; then
    output "Removing phpMyAdmin files..."
    rm -rf /var/www/phpmyadmin
    if [ "$OS" != "centos" ]; then
      unlink /etc/nginx/sites-enabled/phpmyadmin.conf
      rm -f /etc/nginx/sites-available/phpmyadmin.conf
    else
      rm -f /etc/nginx/conf.d/phpmyadmin.conf
    fi
    mysql -u root -e "DROP USER IF EXISTS 'pma'@'localhost';"
    systemctl restart nginx
    success "Removed phpMyAdmin files."
  fi
}

rm_docker_containers() {
  output "Removing docker containers and images..."

  docker system prune -a -f

  success "Removed docker containers and images."
}

rm_wings_files() {
  output "Removing wings files..."

  systemctl disable --now wings
  [ -f /etc/systemd/system/wings.service ] && rm -rf /etc/systemd/system/wings.service

  [ -d /etc/loaf-panel ] && rm -rf /etc/loaf-panel
  [ -f /usr/local/bin/wings ] && rm -rf /usr/local/bin/wings
  [ -d /var/lib/loaf-panel ] && rm -rf /var/lib/loaf-panel
  success "Removed wings files."
}

rm_services() {
  output "Removing services..."
  systemctl disable --now pteroq
  rm -rf /etc/systemd/system/pteroq.service
  case "$OS" in
  debian | ubuntu)
    systemctl disable --now redis-server
    ;;
  centos)
    systemctl disable --now redis
    systemctl disable --now php-fpm
    rm -rf /etc/php-fpm.d/www-loaf-panel.conf
    ;;
  esac
  success "Removed services."
}

rm_cron() {
  output "Removing cron jobs..."
  crontab -l | grep -vF "* * * * * php /var/www/loaf-panel/artisan schedule:run >> /dev/null 2>&1" | crontab -
  success "Removed cron jobs."
}

rm_database() {
  output "Removing database..."
  mysql -u root -e "DROP USER IF EXISTS 'loafpaneluser'@'127.0.0.1';"
  mysql -u root -e "DROP DATABASE IF EXISTS loafpanel;"
  success "Removed database."
}

# --------------- Main functions --------------- #

perform_uninstall() {
  output "Uninstalling Loaf Panel..."
  [ "$RM_PANEL" == true ] && rm_panel_files
  [ "$RM_PANEL" == true ] && [ "$RM_PHPMYADMIN" == true ] && rm_phpmyadmin_files
  [ "$RM_PANEL" == true ] && rm_services
  [ "$RM_PANEL" == true ] && rm_cron
  [ "$RM_PANEL" == true ] && rm_database
  [ "$RM_WINGS" == true ] && rm_wings_files
  [ "$RM_WINGS" == true ] && rm_docker_containers
  success "Uninstallation of Loaf Panel is complete."
}

# Entrypoint
main() {
  perform_uninstall
}

main

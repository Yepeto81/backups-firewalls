#!/bin/bash

# Variables comunes para todos los dispositivos
DATE=$(date +"%Y%m%d_%H%M%S")
SSH_KEY="${HOME}/.ssh/id_rsa"

# Función para cargar variables específicas de Fortigate
set_fortigate_vars() {
    IP_EQUIPO="10.161.69.201"
    USER_BACKUP="backups"
    BACKUPS_DIR="/tmp/fortigate_backups"
    SSH_PORT="22"
    BACKUP_EXT=".conf"
    BACKUP_FILE="${BACKUPS_DIR}/config_${DATE}${BACKUP_EXT}"
}

# Función para cargar variables específicas de Huawei
set_huawei_vars() {
    IP_EQUIPO="IP_HUAWEI_AQUI"
    USER_BACKUP="usuario_huawei"
    BACKUPS_DIR="/tmp/huawei_backups"
    SSH_PORT="22"
    BACKUP_EXT=".cfg"
    BACKUP_FILE="${BACKUPS_DIR}/backup_${DATE}${BACKUP_EXT}"
}

# Función para cargar variables específicas de pfSense
set_pfsense_vars() {
    IP_EQUIPO="IP_PFSENSE_AQUI"
    USER_BACKUP="usuario_pfsense"
    BACKUPS_DIR="/tmp/pfsense_backups"
    SSH_PORT="22"
    BACKUP_EXT=".xml"
    BACKUP_FILE="${BACKUPS_DIR}/backup_${DATE}${BACKUP_EXT}"
}
#!/bin/bash

# Para cargar la llave pub en el forti son los siguientes comandos:
# $ config system admin
# $ edit backups
# $ set ssh-public-key1 "ssh-rsa AAAAB3NzaC1yc2E...(tu clave pública completa)"
# $ end


# Configuración
FORTIGATE_IP="XX.XX.XX.XX" 		# agregar la IP del forti
FORTIGATE_USER="backup"		# usuario que realizara la tarea, previa creacion en el forti
SSH_KEY="${HOME}/.ssh/id_rsa"		# llave privada, se debe setear la llave pub en el usuario del forti via cli 
BACKUP_DIR="/tmp/fortigate_backups"	# Ruta donde se alojaran los backups
SSH_PORT="22"				# Puerto de escucha de SSH del fortigate
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/config_${TIMESTAMP}.conf"

# Crear directorio de backups si no existe
mkdir -p "${BACKUP_DIR}"

# Ejecutar backup via SSH
echo "Iniciando backup de Fortigate..."
ssh -p${SSH_PORT} ${FORTIGATE_USER}@${FORTIGATE_IP} "show full-configuration" > "${BACKUP_FILE}"

# Manejo de resultados
if [ $? -eq 0 ]; then
    echo "Backup exitoso!"
        
    # Comprimir y eliminar original
    gzip "${BACKUP_FILE}"
    echo "Backup comprimido: ${BACKUP_FILE}.gz"
    
    # Rotación de backups (conservar últimos 7 días)
    find "${BACKUP_DIR}" -name "*.conf.gz" -mtime +7 -delete
    exit 0
else
    echo "Error en el backup!"
    echo "Código de error: $?"
    exit 1
fi


#!/bin/bash

# Para cargar la llave pub en el forti son los siguientes comandos:
# $ config system admin
# $ edit backups
# $ set ssh-public-key1 "ssh-rsa AAAAB3NzaC1yc2E...(tu clave pública completa)"
# $ end

# Cargar variables comunes y específicas del dispositivo
source /var/common_vars.sh
set_fortigate_vars

# Configuración
SSH_KEY="${HOME}/.ssh/id_rsa"		# llave privada, se debe setear la llave pub en el usuario del forti via cli 
SSH_PORT="22"				# Puerto de escucha de SSH del fortigate

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


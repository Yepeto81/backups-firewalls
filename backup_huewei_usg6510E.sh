#!/bin/bash

# Configuración básica
ROUTER_IP="192.168.128.1"          # Cambiar por la IP real del router
USER="init"                     # Usuario SSH del router
PASSWORD="Init2024colombino$"           # Contraseña SSH del router
BACKUP_DIR="/backups/huawei"     # Directorio donde guardar los backups
LOG_FILE="/var/log/huawei_backup.log"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="backup-$DATE.cfg"

# Crear directorio de backups si no existe
mkdir -p $BACKUP_DIR

# Inicio del proceso
echo "Iniciando backup el $(date)" >> $LOG_FILE

# Ejecutar comando de backup en el router
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $USER@$ROUTER_IP << EOF >> $LOG_FILE 2>&1
system-view
<<<<<<< HEAD
save /vrpcfg/$BACKUP_FILE
=======
save /$BACKUP_FILE
>>>>>>> 7f060c4 (Resuelve conflictos de fusión)
y
quit
EOF

# Descargar el archivo de configuración
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no -o ConnectTimeout=10 $USER@$ROUTER_IP:/$BACKUP_FILE $BACKUP_DIR/ >> $LOG_FILE 2>&1

# Verificar si la transferencia fue exitosa
if [ $? -eq 0 ]; then
    echo "Backup exitoso: $BACKUP_DIR/$BACKUP_FILE" >> $LOG_FILE
    
    # Opcional: Eliminar el backup del router
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@$ROUTER_IP "rm /vrpcfg/$BACKUP_FILE" >> $LOG_FILE 2>&1
else
    echo "Error en la transferencia del backup" >> $LOG_FILE
    exit 1
fi

echo "Backup completado el $(date)" >> $LOG_FILE
echo "----------------------------------------" >> $LOG_FILE

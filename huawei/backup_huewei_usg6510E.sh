#!/bin/bash

# Configuración
ROUTER_IP="XX.XX.XX.XX"
USER="backup"
PASSWORD="PASSWORD"
BACKUP_DIR="/tmp/huawei/"
LOG_FILE="/tmp/huawei/huawei_backup.log"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="backup-$DATE.cfg"


mkdir -p $BACKUP_DIR
echo "Iniciando backup el $(date)" | tee -a $LOG_FILE

# ------------------------------------------------------------
# Paso 1: Crear backup en el router
# ------------------------------------------------------------
echo "Ejecutando comando save en el router..." | tee -a $LOG_FILE
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@$ROUTER_IP << EOF >> $LOG_FILE 2>&1
save /$BACKUP_FILE
y
quit
EOF

#debug_pause "Post-SSH (Creación backup)"
#echo "Últimas líneas del log:" && tail -n 5 $LOG_FILE

# ------------------------------------------------------------
# Paso 2: Esperar generación del archivo
# ------------------------------------------------------------
echo "Esperando 10 segundos..." | tee -a $LOG_FILE
for i in {1..10}; do
    echo -n "."
    sleep 1
done
echo

# ------------------------------------------------------------
# Paso 3: Descargar archivo
# ------------------------------------------------------------
echo "Iniciando descarga SFTP..." | tee -a $LOG_FILE
sshpass -p "$PASSWORD" sftp -o StrictHostKeyChecking=no $USER@$ROUTER_IP:/$BACKUP_FILE $BACKUP_DIR/


#debug_pause "Post-SFTP (Descarga)"
echo "Contenido del directorio local:" && ls -lh $BACKUP_DIR | tee -a $LOG_FILE

# ------------------------------------------------------------
# Paso 4: Verificación y limpieza
# ------------------------------------------------------------
echo "limpieza de archivos en el rourter" | tee -a $LOG_FILE
# Limpiar archivo en el router
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@$ROUTER_IP << EOF >> $LOG_FILE 2>&1
delete /$BACKUP_FILE
Y
quit
EOF
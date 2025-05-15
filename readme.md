Backup Automatizado de Firewalls
Este repositorio contiene scripts para realizar backups automáticos de configuraciones de firewalls pfSense, Fortigate y Huawei USG6510E.

📋 Contenido
Requisitos Generales

pfSense

Configuración Previa

Uso

Fortigate

Configuración Previa

Uso

Huawei USG6510E

Uso

Automatización con Cron

Consideraciones de Seguridad

Estructura de Archivos

⚙️ Requisitos Generales
Sistemas basados en Unix/Linux.

Paquetes:

cURL (para pfSense).

ssh/scp (para Fortigate y Huawei).

sshpass (solo para Huawei).

gzip (compresión en Fortigate).

🔐 pfSense
Configuración Previa
Crear un usuario en pfSense con permisos de solo lectura (ej: auto-backup).

Asegurar acceso HTTPS al panel de pfSense.

Uso
Editar variables en el script:

bash
PFSENSE_HOST="https://TU_IP_PFSENSE"  # URL de acceso
PFSENSE_USER="TU_USUARIO"            # Usuario con permisos
PFSENSE_PASS="TU_CONTRASEÑA"         # Contraseña del usuario
BACKUP_DIR="/ruta/backups/pfsense"   # Directorio de backups
Ejecutar:

bash
chmod +x pfsense_backup.sh
./pfsense_backup.sh
Características:

Excluye datos RRD y paquetes por defecto.

Genera backups en formato XML con marca de tiempo.

🛡️ Fortigate
Configuración Previa
Crear usuario backups en Fortigate con acceso SSH.

Configurar clave SSH pública en el usuario:

bash
config system admin
edit backups
set ssh-public-key1 "TU_CLAVE_PUBLICA"
end
Uso
Editar variables en el script:

bash
FORTIGATE_IP="TU_IP_FORTIGATE"
FORTIGATE_USER="backups"
SSH_KEY="~/.ssh/id_rsa"              # Ruta clave privada
BACKUP_DIR="/ruta/backups/fortigate"
Ejecutar:

bash
chmod +x fortigate_backup.sh
./fortigate_backup.sh
Características:

Comprime backups con gzip.

Retiene solo backups de los últimos 7 días.

📡 Huawei USG6510E
Uso
Editar variables en el script:

bash
ROUTER_IP="TU_IP_HUAWEI"
USER="admin"
PASSWORD="TU_CONTRASEÑA"             # ¡Almacenar de forma segura!
BACKUP_DIR="/ruta/backups/huawei"
Instalar sshpass si no está disponible:

bash
sudo apt-get install sshpass  # Debian/Ubuntu
Ejecutar:

bash
chmod +x huawei_backup.sh
./huawei_backup.sh
Características:

Registra logs en /var/log/huawei_backup.log.

Elimina automáticamente el backup del equipo después de la descarga.

⏰ Automatización con Cron
Ejemplo para ejecutar diariamente a las 2:00 AM:

bash
0 2 * * * /ruta/scripts/pfsense_backup.sh
0 2 * * * /ruta/scripts/fortigate_backup.sh
0 2 * * * /ruta/scripts/huawei_backup.sh
🔒 Consideraciones de Seguridad
Nunca almacenes contraseñas en texto plano (usar variables de entorno o gestores de secretos).

Restringe permisos de los scripts:

bash
chmod 700 *.sh
Para Huawei, considera migrar a autenticación por claves SSH en lugar de sshpass.

Usa certificados HTTPS válidos en pfSense para evitar riesgos.

📂 Estructura de Archivos
/backup_scripts/
├── pfsense_backup.sh
├── fortigate_backup.sh
├── huawei_backup.sh
└── conf_backup/
    ├── pfsense/
    │   └── config-20231201120000.xml
    ├── fortigate/
    │   └── config_20231201_120000.conf.gz
    └── huawei/
        └── backup-20231201-120000.cfg
⭐ ¡Importante!
Verifica periódicamente que los backups se generen correctamente y realiza restauraciones de prueba.

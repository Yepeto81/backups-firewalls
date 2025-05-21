Backup Automatizado de Firewalls
Este repositorio contiene scripts para realizar backups automáticos de configuraciones de firewalls pfSense, Fortigate y Huawei USG6510E.

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

PFSENSE_HOST="https://TU_IP_PFSENSE"  # URL de acceso
PFSENSE_USER="TU_USUARIO"            # Usuario con permisos
PFSENSE_PASS="TU_CONTRASEÑA"         # Contraseña del usuario
BACKUP_DIR="/ruta/backups/pfsense"   # Directorio de backups
Ejecutar:

chmod +x pfsense_backup.sh
./pfsense_backup.sh
Características:

Excluye datos PRD y paquetes por defecto.

Genera backups en formato XML con marca de tiempo.

🛡️ Fortigate
Configuración Previa
Crear usuario backups en Fortigate con acceso SSH.

Configurar clave SSH pública en el usuario:

config system admin
edit backups
set ssh-public-key1 "TU_CLAVE_PUBLICA"
end
Uso

Editar variables en el script:

FORTIGATE_IP="TU_IP_FORTIGATE"
FORTIGATE_USER="backups"
SSH_KEY="~/.ssh/id_rsa"              # Ruta clave privada
BACKUP_DIR="/ruta/backups/fortigate"


chmod +x fortigate_backup.sh
./fortigate_backup.sh

Características:
Comprime backups con gzip.
Retiene solo backups de los últimos 7 días.

📡 Huawei USG6510E
Editar variables en el script:

ROUTER_IP="TU_IP_HUAWEI"
USER="admin"
PASSWORD="TU_CONTRASEÑA"             # ¡Almacenar de forma segura!
BACKUP_DIR="/ruta/backups/huawei"
Instalar sshpass si no está disponible:

sudo apt-get install sshpass  


chmod +x huawei_backup.sh
./huawei_backup.sh

Características:
Registra logs en /var/log/huawei_backup.log.

Elimina automáticamente el backup del equipo después de la descarga.

⏰ Automatización con Cron
Ejemplo para ejecutar diariamente a las 2:00 AM:

0 2 * * * /ruta/scripts/pfsense_backup.sh
0 2 * * * /ruta/scripts/fortigate_backup.sh
0 2 * * * /ruta/scripts/huawei_backup.sh

🔒 Consideraciones de Seguridad
Nunca almacenes contraseñas en texto plano (usar variables de entorno o gestores de secretos).

Restringe permisos de los scripts:

chmod 700 *.sh

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

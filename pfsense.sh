#!/bin/sh

VERSION="2023.12_cURL"
RUNDIR="$( cd "$( dirname "$0" )" && pwd )"

##############################
######### VARIABLES  #########

# pfSense host O IP (nota: no incluir la / final, de otra manera el backup va a fallar)
PFSENSE_HOST=https://192.168.0.1

# login - password
PFSENSE_USER=auto-backup
PFSENSE_PASS=yhVlMnfNI4IR5G1IqppRag==

# Directorio donde se alojará el backup
BACKUP_DIR="${RUNDIR}/conf_backup"

BACKUP_RRD=0          # 0 = Excluir datos RRD
BACKUP_PKGINFO=0      # 0 = Excluir información de paquetes

######## FIN DE VARIABLES ########
##############################

echo
echo "*** backup-automatica ***"
echo

# Corregir verificación de cURL (eliminar $i)
if ! curl -V >/dev/null 2>&1; then
    echo "ERROR: cURL debe estar instalado para ejecutar el script."
    exit 1
fi

# Directorio de backup
mkdir -p "$BACKUP_DIR" || { echo "Error creando directorio"; exit 1; }

# Archivos temporales
COOKIE_FILE="$(mktemp)" || exit 1
CSRF1_TOKEN="$(mktemp)" || exit 1
CSRF2_TOKEN="$(mktemp)" || exit 1
CONFIG_TMP="$(mktemp)" || exit 1

# Configurar parámetros de backup
RRD=""; PKG=""; PW=""
[ "$BACKUP_RRD" = "0" ] && RRD="&donotbackuprrd=yes"
[ "$BACKUP_PKGINFO" = "0" ] && PKG="&nopackages=yes"
[ -n "$BACKUP_PASSWORD" ] && PW="&encrypt_password=$BACKUP_PASSWORD&encrypt_passconf=$BACKUP_PASSWORD&encrypt=on"

# Obtener primer token CSRF
if ! curl -Ss --noproxy '*' --insecure --cookie-jar "$COOKIE_FILE" \
    "$PFSENSE_HOST/diag_backup.php" | grep "name='__csrf_magic'" \
    | sed -n 's/.*value="\([^"]*\)".*/\1/p' > "$CSRF1_TOKEN"; then
    echo "ERROR: Obteniendo CSRF1"
    exit 1
fi

# Iniciar sesión
if ! curl -Ss --noproxy '*' --insecure --location --cookie-jar "$COOKIE_FILE" --cookie "$COOKIE_FILE" \
    --data-urlencode "login=Login" \
    --data-urlencode "usernamefld=${PFSENSE_USER}" \
    --data-urlencode "passwordfld=${PFSENSE_PASS}" \
    --data-urlencode "__csrf_magic=$(cat "$CSRF1_TOKEN")" \
    "$PFSENSE_HOST/diag_backup.php" | grep "name='__csrf_magic'" \
    | sed -n 's/.*value="\([^"]*\)".*/\1/p' > "$CSRF2_TOKEN"; then
    echo "ERROR: Iniciando sesión"
    exit 1
fi

# Descargar configuración usando variables RRD/PKG/PW
if ! curl -Ss --noproxy '*' --insecure --cookie "$COOKIE_FILE" \
    --data "Submit=download&download=download${RRD}${PKG}${PW}&__csrf_magic=$(cat "$CSRF2_TOKEN")" \
    "$PFSENSE_HOST/diag_backup.php" > "$CONFIG_TMP"; then
    echo "ERROR: Descargando configuración"
    exit 1
fi

# Verificar credenciales
if grep -qi 'username or password' "$CONFIG_TMP"; then
    echo "ERROR: Autenticación fallida"
    exit 1
fi

# Verificar respuesta válida
if grep -qi 'doctype html' "$CONFIG_TMP"; then
    echo "ERROR: URL incorrecta"
    exit 1
fi

# Generar nombre de archivo
hostname=$(sed -n 's/<hostname>\([^<]*\).*/\1/p' "$CONFIG_TMP")
domain=$(sed -n 's/<domain>\([^<]*\).*/\1/p' "$CONFIG_TMP")
NOW=$(date +%Y%m%d%H%M%S)
backup_file="config-${NOW}.xml"

# Mover archivo temporal a destino final
if mv "$CONFIG_TMP" "$BACKUP_DIR/$backup_file"; then
    echo "Backup exitoso: $BACKUP_DIR/$backup_file"
else
    echo "ERROR: Moviendo archivo de backup"
    exit 1
fi

# Limpieza
rm -f "$COOKIE_FILE" "$CSRF1_TOKEN" "$CSRF2_TOKEN"

exit 0


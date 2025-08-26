#!/bin/bash
set -e  # Detener el script si hay un error crítico

# =============================
# VALIDACIÓN DE EJECUCIÓN
# =============================
if [ "$EUID" -eq 0 ]; then
    echo "❌ No ejecutes este script como root. Usa: bash $0"
    exit 1
fi

# Validar sudo una vez
sudo -v

# =============================
# COLORES PARA MENSAJES
# =============================
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

log() {
    echo -e "${GREEN}[+]${NC} $1"
}
warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}
error() {
    echo -e "${RED}[-]${NC} $1"
}

# =============================
# FUNCIONES AUXILIARES
# =============================
install_if_missing() {
    local cmd="$1"
    local pkg="$2"
    if command -v "$cmd" &> /dev/null; then
        log "$pkg ya está instalado, saltando..."
    else
        log "Instalando $pkg..."
        sudo apt install -y "$pkg"
    fi
}

check_tool() {
    if command -v "$1" &> /dev/null; then
        log "$2 instalado correctamente"
    else
        error "$2 no se detectó correctamente"
    fi
}

# =============================
# INICIO DE INSTALACIÓN
# =============================

log "Actualizando lista de paquetes..."
sudo apt update -y

log "Instalando herramientas esenciales..."
install_if_missing curl curl
install_if_missing wget wget
install_if_missing git git
install_if_missing make build-essential
install_if_missing gpg gnupg2
install_if_missing unzip unzip
install_if_missing jq jq
install_if_missing exiftool exiftool

log "Instalando herramientas de pentesting..."
install_if_missing wfuzz wfuzz
install_if_missing gobuster gobuster
install_if_missing hashcat hashcat
install_if_missing john john
install_if_missing nmap nmap
install_if_missing wireshark wireshark
install_if_missing nikto nikto
install_if_missing sqlmap sqlmap
install_if_missing ifconfig net-tools
install_if_missing tcpdump tcpdump
install_if_missing hydra hydra
install_if_missing dirb dirb
install_if_missing dnsenum dnsenum
install_if_missing adb adb
install_if_missing whatweb whatweb
install_if_missing aircrack-ng aircrack-ng
install_if_missing hcxtools hcxtools
install_if_missing hcxdumptool hcxdumptool
install_if_missing binwalk binwalk
install_if_missing sherlock sherlock

# =============================
# Instalar Burp Suite Community
# =============================
log "Iniciando instalación de Burp Suite Community..."

# Ejecutamos el script de Python desde el bash para obtener y descargar Burp Suite
python3 <<'EOF'
import requests
import re
import os
import stat
import subprocess

def extraer_ultima_version_comunidad_linux():
    url = "https://portswigger.net/burp/releases/community/latest"
    response = requests.get(url)
    
    if response.status_code != 200:
        print("Error al obtener la página.")
        return None
    
    html = response.text
    
    version_match = re.search(r'Professional / Community (\d+\.\d+\.\d+)', html)
    if not version_match:
        print("No se encontró la versión en la página.")
        return None
    
    version = version_match.group(1)
    print(f"Versión detectada: {version}")
    
    download_url = f"https://portswigger.net/burp/releases/download?product=community&version={version}&type=Linux"
    
    return version, download_url

def descargar_burpsuite_linux(url, version):
    file_name = f"burpsuite_community_linux_v{version}_64.sh"
    
    print(f"Descargando desde: {url}")
    
    with requests.get(url, stream=True) as r:
        if r.status_code != 200:
            print(f"Error al descargar: Status code {r.status_code}")
            return None
        
        with open(file_name, "wb") as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
    
    print(f"Archivo descargado: {file_name}")
    return file_name

def dar_permisos_ejecucion(file_path):
    st = os.stat(file_path)
    os.chmod(file_path, st.st_mode | stat.S_IEXEC)
    print(f"Permisos de ejecución asignados a: {file_path}")

def ejecutar_instalador_con_sudo(file_path):
    print(f"Ejecutando instalador con sudo: {file_path}")
    try:
        subprocess.run(["sudo", f"./{file_path}"], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error al ejecutar el instalador: {e}")

if __name__ == "__main__":
    resultado = extraer_ultima_version_comunidad_linux()
    if resultado:
        version, url_descarga = resultado
        archivo = descargar_burpsuite_linux(url_descarga, version)
        if archivo:
            dar_permisos_ejecucion(archivo)
            ejecutar_instalador_con_sudo(archivo)
EOF

# =============================
# Listo
# =============================
log "Instalación completada."

# =============================
# SecLists + Rockyou
# =============================
WORDLISTS_DIR="/usr/share/wordlists"
SECLISTS_DIR="$WORDLISTS_DIR/SecLists"
ROCKYOU_PATH="$WORDLISTS_DIR/rockyou.txt"

log "Instalando SecLists desde GitHub..."
if [ -d "$SECLISTS_DIR" ]; then
    log "SecLists ya existe en $SECLISTS_DIR, actualizando..."
    cd "$SECLISTS_DIR" && sudo git pull
else
    sudo git clone https://github.com/danielmiessler/SecLists.git "$SECLISTS_DIR"
fi

log "Verificando rockyou.txt..."
if [ -f "$ROCKYOU_PATH" ]; then
    log "rockyou.txt ya existe en $ROCKYOU_PATH"
else
    warn "rockyou.txt no encontrado. Descargando desde fuente confiable..."
    wget -q https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -O /tmp/rockyou.txt
    sudo mv /tmp/rockyou.txt "$ROCKYOU_PATH"
    log "rockyou.txt descargado en $ROCKYOU_PATH"
fi

# Resto del script para otras herramientas...
# ...

# =============================
# Lista de verificación
# =============================
echo "Verificando herramientas instaladas..."
check_tool burpsuite "Burp Suite"

# Fin

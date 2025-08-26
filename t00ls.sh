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

check_hcxtools() {
    if command -v hcxpcapngtool &> /dev/null || \
       command -v hcxhashtool &> /dev/null; then
        log "hcxtools instalado correctamente"
    else
        error "hcxtools no se detectó correctamente"
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
# Ruby + Gems (Evil-WinRM & Wpscan)
# =============================
log "Instalando Ruby y dependencias..."
install_if_missing gem ruby-rubygems
install_if_missing ruby-dev ruby-dev

log "Instalando Evil-WinRM con gem..."
if gem list -i evil-winrm &> /dev/null; then
    log "evil-winrm ya está instalado."
else
    sudo gem install evil-winrm
fi

log "Instalando Wpscan con gem..."
if gem list -i wpscan &> /dev/null; then
    log "wpscan ya está instalado."
else
    sudo gem install wpscan
fi

# =============================
# CrackMapExec con Snap
# =============================
log "Instalando CrackMapExec con snap..."
if command -v crackmapexec &> /dev/null; then
    log "CrackMapExec ya está instalado."
else
    sudo snap install crackmapexec
fi

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

# =============================
# Metasploit
# =============================
log "Instalando Metasploit Framework..."
if command -v msfconsole &> /dev/null; then
    log "Metasploit ya está instalado, saltando..."
else
    curl -s https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
    chmod +x msfinstall
    sudo ./msfinstall
    rm msfinstall
fi

# =============================
# scrcpy
# =============================
log "Instalando scrcpy actualizado desde GitHub..."
if command -v scrcpy &> /dev/null; then
    log "scrcpy ya está instalado, saltando compilación..."
else
    sudo apt install -y ffmpeg libsdl2-2.0-0 adb wget \
        gcc git pkg-config meson ninja-build libsdl2-dev \
        libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
        libswresample-dev libusb-1.0-0 libusb-1.0-0-dev

    rm -rf /tmp/scrcpy
    git clone https://github.com/Genymobile/scrcpy /tmp/scrcpy
    cd /tmp/scrcpy
    ./install_release.sh
    cd ~
    rm -rf /tmp/scrcpy
fi

# =============================
# Alias
# =============================
log "Añadiendo alias útiles a ~/.bashrc ..."
if ! grep -q "# ====== HACKING ALIASES ======" ~/.bashrc; then
cat <<EOF >> ~/.bashrc

# ====== HACKING ALIASES ======
alias rockyou='$ROCKYOU_PATH'
alias seclists='cd $SECLISTS_DIR'
alias msf='msfconsole'
alias aconnect='adb connect 127.0.0.1:5555'
alias scr='scrcpy --max-fps 30 --turn-screen-off'
EOF
fi

log "Aplicando alias..."
source ~/.bashrc || true

# =============================
# LISTA DE VERIFICACIÓN FINAL
# =============================
echo ""
echo "==============================="
echo "🧾 LISTA FINAL DE HERRAMIENTAS"
echo "==============================="

check_tool wfuzz "Wfuzz"
check_tool gobuster "Gobuster"
check_tool hashcat "Hashcat"
check_tool john "John the Ripper"
check_tool nmap "Nmap"
check_tool wireshark "Wireshark"
check_tool nikto "Nikto"
check_tool sqlmap "SQLMap"
check_tool tcpdump "TCPDump"
check_tool hydra "Hydra"
check_tool dirb "Dirb"
check_tool dnsenum "Dnsenum"
check_tool adb "ADB (Android Debug Bridge)"
check_tool scrcpy "scrcpy (control de Android)"
check_tool msfconsole "Metasploit Framework"
check_tool jq "jq (JSON parser)"
check_tool exiftool "Exiftool (metadatos)"
check_tool whatweb "Whatweb"
check_tool aircrack-ng "Aircrack-ng"
check_tool hcxdumptool "HCXDumpTool"
check_hcxtools
check_tool binwalk "Binwalk"
check_tool crackmapexec "CrackMapExec"
check_tool evil-winrm "Evil-WinRM"
check_tool wpscan "Wpscan"
check_tool sherlock "Sherlock"

[ -f "$ROCKYOU_PATH" ] && log "rockyou.txt disponible en $ROCKYOU_PATH" || error "rockyou.txt faltante"
[ -d "$SECLISTS_DIR" ] && log "SecLists instalado en $SECLISTS_DIR" || error "SecLists faltante"

echo ""
log "¡Tu entorno está listo, kr1pt0n!"
warn "Reinicia tu sesión para aplicar los permisos de Wireshark correctamente."

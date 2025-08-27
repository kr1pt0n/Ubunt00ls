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
# COLORES Y FORMATO
# =============================
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
NC="\e[0m"

# Delay para no parecer robot
DELAY=0.2

# =============================
# BANNER UBUNT00L$
# =============================
echo -e "${GREEN}"
cat << "EOF"

     /\                 /\ 
    / \'._   (\_/)   _.'/ \ 
   /_.''._'--('.')--'_.''._\ 
   | \_ / `;=/ " \=;` \ _/ | 
    \/ `\__|`\___/`|__/`  \/ 
         \(/|\)/       
        ubunt00l$

EOF
echo -e "${NC}"

# =============================
# LOGGING ESTÉTICO
# =============================
log_ok() {
    printf "%-35s [%b✔ OK%b]\n" "$1" "${GREEN}${BOLD}" "${NC}"
}
log_fail() {
    printf "%-35s [%b✘ FAIL%b]\n" "$1" "${RED}${BOLD}" "${NC}"
}
log_info() {
    printf "%-35s [%b* INFO%b]\n" "$1" "${BLUE}" "${NC}"
}
log_warn() {
    printf "%-35s [%b! WARN%b]\n" "$1" "${YELLOW}" "${NC}"
}

# =============================
# FUNCIONES AUXILIARES
# =============================
install_if_missing() {
    local cmd="$1"
    local pkg="$2"
    if command -v "$cmd" &> /dev/null; then
        log_ok "$pkg"
    else
        log_info "$pkg instalando..."
        sleep $DELAY
        if sudo apt install -y "$pkg" &>/dev/null; then
            log_ok "$pkg"
        else
            log_fail "$pkg"
        fi
    fi
    sleep $DELAY
}

check_tool() {
    local cmd="$1"
    local name="$2"
    if command -v "$cmd" &> /dev/null; then
        log_ok "$name"
    else
        log_fail "$name"
    fi
}

check_hcxtools() {
    if command -v hcxpcapngtool &> /dev/null || \
       command -v hcxhashtool &> /dev/null; then
        log_ok "hcxtools"
    else
        log_fail "hcxtools"
    fi
}

# =============================
# INICIO DE INSTALACIÓN
# =============================
log_info "Actualizando lista de paquetes..."
sudo apt update -y

log_info "Instalando herramientas esenciales..."
install_if_missing curl curl
install_if_missing wget wget
install_if_missing git git
install_if_missing make build-essential
install_if_missing gpg gnupg2
install_if_missing unzip unzip
install_if_missing jq jq
install_if_missing exiftool exiftool

log_info "Instalando herramientas de pentesting..."
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
log_info "Instalando Ruby y dependencias..."
install_if_missing gem ruby-rubygems
install_if_missing ruby-dev ruby-dev

log_info "Instalando Evil-WinRM..."
if gem list -i evil-winrm &> /dev/null; then
    log_ok "evil-winrm"
else
    sudo gem install evil-winrm && log_ok "evil-winrm" || log_fail "evil-winrm"
fi

log_info "Instalando Wpscan..."
if gem list -i wpscan &> /dev/null; then
    log_ok "wpscan"
else
    sudo gem install wpscan && log_ok "wpscan" || log_fail "wpscan"
fi

# =============================
# CrackMapExec con Snap
# =============================
log_info "Instalando CrackMapExec..."
if command -v crackmapexec &> /dev/null; then
    log_ok "crackmapexec"
else
    sudo snap install crackmapexec && log_ok "crackmapexec" || log_fail "crackmapexec"
fi

# =============================
# SecLists + Rockyou
# =============================
WORDLISTS_DIR="/usr/share/wordlists"
SECLISTS_DIR="$WORDLISTS_DIR/SecLists"
ROCKYOU_PATH="$WORDLISTS_DIR/rockyou.txt"

log_info "Instalando SecLists..."
if [ -d "$SECLISTS_DIR/.git" ]; then
    log_info "SecLists existe, reseteando..."
    cd "$SECLISTS_DIR"
    sudo git fetch --all &>/dev/null
    sudo git reset --hard origin/master &>/dev/null
    log_ok "SecLists"
else
    sudo rm -rf "$SECLISTS_DIR" 2>/dev/null || true
    sudo git clone https://github.com/danielmiessler/SecLists.git "$SECLISTS_DIR" &>/dev/null \
        && log_ok "SecLists" || log_fail "SecLists"
fi

log_info "Verificando rockyou.txt..."
if [ -f "$ROCKYOU_PATH" ]; then
    log_ok "rockyou.txt"
else
    log_warn "Descargando rockyou.txt..."
    wget -q https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -O /tmp/rockyou.txt
    sudo mv /tmp/rockyou.txt "$ROCKYOU_PATH"
    log_ok "rockyou.txt"
fi
 
# =============================
# Metasploit
# =============================
log_info "Instalando Metasploit..."
if command -v msfconsole &> /dev/null; then
    log_ok "Metasploit"
else
    curl -s https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
    chmod +x msfinstall
    sudo ./msfinstall && log_ok "Metasploit" || log_fail "Metasploit"
    rm msfinstall
fi

# =============================
# scrcpy
# =============================
log_info "Instalando scrcpy..."
if command -v scrcpy &> /dev/null; then
    log_ok "scrcpy"
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
    log_ok "scrcpy"
fi

# =============================
# Alias
# =============================
log_info "Añadiendo alias..."
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

source ~/.bashrc || true
log_ok "alias añadidos"

# =============================
# EXPLOIT-DB / SEARCHSPLOIT + SHELLCODES
# =============================
log_info "Instalando Exploit-DB (Searchsploit) y Shellcodes..."

REPOS=( "exploitdb" "exploitdb-papers" )
for repo in "${REPOS[@]}"; do
    INSTALL_DIR="/opt/$repo"
    if [ -d "$INSTALL_DIR" ]; then
        log_info "$repo ya existe, ajustando permisos..."
    else
        log_info "Clonando $repo..."
        sudo git clone "https://gitlab.com/exploit-database/$repo.git" "$INSTALL_DIR" &>/dev/null \
            && log_ok "$repo" || log_fail "$repo"
    fi

    # Ajustar propiedad al usuario actual
    sudo chown -R "$USER:$USER" "$INSTALL_DIR"
    log_info "Propietario de $repo ajustado a $USER"

    # Marcar safe.directory en Git
    git config --global --add safe.directory "$INSTALL_DIR"
done

# Crear enlace simbólico searchsploit si no existe
if [ -L "/usr/local/bin/searchsploit" ]; then
    log_ok "Enlace searchsploit"
else
    sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit \
        && log_ok "Enlace searchsploit" || log_fail "Enlace searchsploit"
fi

# Eliminar .searchsploit_rc si existe
RC_FILE="$HOME/.searchsploit_rc"
if [ -f "$RC_FILE" ]; then
    rm "$RC_FILE"
    log_info "Archivo .searchsploit_rc eliminado"
fi

# Crear directorio de shellcodes si no existe
SHELLCODE_DIR="/opt/exploitdb/shellcodes"
if [ -d "$SHELLCODE_DIR" ]; then
    log_ok "Shellcodes ya disponibles"
else
    mkdir -p "$SHELLCODE_DIR" && log_ok "Directorio Shellcodes creado"
fi

# Actualizar base de datos de exploits y shellcodes
log_info "Actualizando base de datos de exploits y shellcodes..."
searchsploit -u &>/dev/null && log_ok "Base de exploits y shellcodes actualizada" || log_fail "Actualización fallida"

# =============================
# VERIFICACIÓN POST-INSTALACIÓN (CENTRADA)
# =============================

# Colores
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
NC="\e[0m"

# Terminal y caja
TERM_WIDTH=$(tput cols)
[ "$TERM_WIDTH" -lt 60 ] && TERM_WIDTH=60
BOX_WIDTH=60

# Funciones de impresión
print_border() {
    local padding=$(( (TERM_WIDTH - BOX_WIDTH) / 2 ))
    printf "%*s" "$padding" ""
    printf '%b' "$BLUE"
    printf '=%.0s' $(seq 1 $BOX_WIDTH)
    printf '%b\n' "$NC"
}

print_centered() {
    local text="$1"
    local color="${2:-$NC}"
    local padding=$(( (BOX_WIDTH - ${#text}) / 2 ))
    local margin=$(( (TERM_WIDTH - BOX_WIDTH) / 2 ))

    printf "%*s" "$margin" ""
    printf "%b%*s%s%*s%b\n" "$color" "$padding" "" "$text" "$padding" "" "$NC"
}

# Verificación de herramientas
progress_bar() {
    local tool="$1"
    local display="$2"
    local duration=20  # longitud de la barra
    local margin=$(( (TERM_WIDTH - BOX_WIDTH) / 2 ))
    local bar=""
    local percent=0

    # Verificar estado de la herramienta
    if command -v "$tool" &> /dev/null || \
       { [ "$tool" = "rockyou.txt" ] && [ -f "$ROCKYOU_PATH" ]; } || \
       { [ "$tool" = "SecLists" ] && [ -d "$SECLISTS_DIR" ]; }; then
        status="${GREEN}✔ OK${NC}"
    else
        status="${RED}✘ FAIL${NC}"
    fi

    # Mostrar nombre alineado
    printf "%*s" "$margin" ""
    printf "[+] %-22s : [" "$display"

    # Simular carga con porcentaje
    for i in $(seq 1 $duration); do
        bar+="#"
        percent=$(( i * 100 / duration ))

        # Regresar el cursor al inicio de la barra (sin hacer salto de línea)
        printf "\r"
        printf "%*s" "$margin" ""
        printf "[+] %-22s : [${YELLOW}%-20s${NC}] %3d%%" "$display" "$bar" "$percent"

        sleep 0.03
    done

    # Mostrar estado final (✔ OK o ✘ FAIL)
    printf "  %b\n" "$status"
}

# =============================
# TÍTULO
# =============================
clear
print_border
print_centered "🔍 VERIFICACIÓN POST-INSTALACIÓN" "$BOLD$BLUE"
print_border

# =============================
# LISTA DE HERRAMIENTAS
# =============================
tools=(
    "wfuzz Wfuzz"
    "gobuster Gobuster"
    "hashcat Hashcat"
    "john John"
    "nmap Nmap"
    "wireshark Wireshark"
    "nikto Nikto"
    "sqlmap SQLMap"
    "tcpdump TCPDump"
    "hydra Hydra"
    "dirb Dirb"
    "dnsenum Dnsenum"
    "adb ADB"
    "scrcpy scrcpy"
    "msfconsole Metasploit"
    "jq jq"
    "exiftool Exiftool"
    "whatweb Whatweb"
    "aircrack-ng Aircrack-ng"
    "hcxdumptool HCXDumpTool"
    "hcxpcapngtool hcxtools"
    "binwalk Binwalk"
    "crackmapexec CrackMapExec"
    "evil-winrm Evil-WinRM"
    "wpscan Wpscan"
    "sherlock Sherlock"
    "rockyou.txt rockyou.txt"
    "SecLists SecLists"
    "searchsploit Exploit-DB"
)

for t in "${tools[@]}"; do
    tool_name=$(echo $t | awk '{print $1}')
    display_name=$(echo $t | cut -d' ' -f2-)
    progress_bar "$tool_name" "$display_name"
done

# =============================
# MENSAJE FINAL
# =============================
print_border
print_centered "¡Tu entorno está listo-HappyHacking! ✔" "$BOLD$GREEN"
print_centered "Reinicia tu sesión para aplicar permisos de Wireshark." "$BOLD$YELLOW"
print_border

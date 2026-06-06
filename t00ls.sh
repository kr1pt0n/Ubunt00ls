#!/bin/bash
set -e  # Detener el script si hay un error crítico

# =============================
# VALIDACIÓN DE EJECUCIÓN
# =============================
if [ "$EUID" -eq 0 ]; then
    echo "[X] No ejecutes este script como root. Usa: bash $0"
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

DELAY=0.1

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
log_ok() { printf "%-35s [%b✔ OK%b]\n" "$1" "${GREEN}${BOLD}" "${NC}"; }
log_fail() { printf "%-35s [%b✘ FAIL%b]\n" "$1" "${RED}${BOLD}" "${NC}"; }
log_info() { printf "%-35s [%b* INFO%b]\n" "$1" "${BLUE}" "${NC}"; }
log_warn() { printf "%-35s [%b! WARN%b]\n" "$1" "${YELLOW}" "${NC}"; }

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
        if sudo apt install -y "$pkg"; then
            log_ok "$pkg"
        else
            log_fail "$pkg"
            exit 1
        fi
    fi
    sleep $DELAY
}

# =============================
# INICIO DE INSTALACIÓN DE COMPONENTES BASE
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

# Configuración del entorno global del PATH
log_info "Configurando variables de entorno permanentes..."
if ! grep -q "# ====== ENVIROMENT PATHS ======" ~/.bashrc; then
cat << 'EOF' >> ~/.bashrc

# ====== ENVIROMENT PATHS ======
export PATH="$HOME/.local/bin:$HOME/go/bin:/opt/enum4linux-ng:$PATH"
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1
EOF
fi
export PATH="$HOME/.local/bin:$HOME/go/bin:/opt/enum4linux-ng:$PATH"
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

log_info "Instalando dependencias base (APT y Lenguajes)..."
sudo apt install -y pipx git rustc cargo build-essential python3-dev libffi-dev golang libpcap-dev python3-impacket
pipx ensurepath

log_info "Instalando herramientas de pentesting (APT)..."
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
install_if_missing adb adb
install_if_missing whatweb whatweb
install_if_missing aircrack-ng aircrack-ng
install_if_missing binwalk binwalk
install_if_missing smbclient smbclient
install_if_missing sqlite3 sqlite3
install_if_missing medusa medusa

# Java JDK Estable
log_info "Instalando Java JDK..."
install_if_missing java default-jdk

# PostgreSQL
log_info "Instalando PostgreSQL..."
install_if_missing psql postgresql

# =============================
# COMPILACIÓN MANUAL DE SCRCPY (MÉTODO OPTIMIZADO)
# =============================
log_info "Instalando dependencias de compilación para Scrcpy..."
sudo apt install -y ffmpeg libsdl3-0 libusb-1.0-0 adb wget \
                    gcc git pkg-config meson ninja-build libsdl3-dev \
                    libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
                    libswresample-dev libusb-1.0-0-dev libv4l-dev

log_info "Compilando e instalando Scrcpy desde código fuente..."
if command -v scrcpy &>/dev/null; then
    log_ok "Scrcpy (Ya instalado)"
else
    rm -rf /tmp/scrcpy
    git clone https://github.com/Genymobile/scrcpy /tmp/scrcpy
    cd /tmp/scrcpy
    ./install_release.sh
    cd ~
    rm -rf /tmp/scrcpy
    log_ok "Scrcpy (Compilado)"
fi

# Herramientas vía Snaps
log_info "Instalando herramientas vía Snap..."
for snap_pkg in rustscan feroxbuster amass httpx; do
    if command -v "$snap_pkg" &> /dev/null || [ -f "/snap/bin/$snap_pkg" ]; then
        log_ok "$snap_pkg"
    else
        sudo snap install "$snap_pkg" &>/dev/null && log_ok "$snap_pkg" || log_fail "$snap_pkg"
    fi
done

# Herramientas vía PIPX
log_info "Instalando herramientas vía PIPX..."

if command -v nxc &>/dev/null; then
    log_ok "NetExec"
else
    pipx install git+https://github.com/Pennyw0rth/NetExec && log_ok "NetExec" || log_fail "NetExec"
fi

if command -v sherlock &>/dev/null; then
    log_ok "Sherlock"
else
    pipx install sherlock-project && log_ok "Sherlock" || log_fail "Sherlock"
fi

# FFUF con validación estricta
log_info "Instalando FFUF..."
if command -v ffuf &> /dev/null; then
    log_ok "ffuf"
else
    FFUF_VERSION=$(curl -s https://api.github.com/repos/ffuf/ffuf/releases/latest | jq -r '.tag_name' | sed 's/v//')
    wget -q "https://github.com/ffuf/ffuf/releases/download/v${FFUF_VERSION}/ffuf_${FFUF_VERSION}_linux_amd64.tar.gz" -O /tmp/ffuf.tar.gz
    
    tar -xzf /tmp/ffuf.tar.gz -C /tmp/
    sudo mv /tmp/ffuf /usr/local/bin/ffuf
    rm -f /tmp/ffuf.tar.gz
    [ -x /usr/local/bin/ffuf ] && log_ok "ffuf" || log_fail "ffuf"
fi

# CONFIGURACIÓN DE WIRESHARK COMO ROOT EXCLUSIVO
log_info "Configurando Wireshark para ejecución exclusiva como ROOT..."
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure wireshark-common &>/dev/null || true
if [ -f /usr/bin/dumpcap ]; then
    sudo chown root:root /usr/bin/dumpcap
    sudo chmod 700 /usr/bin/dumpcap
fi

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
    sudo gem install evil-winrm &>/dev/null && log_ok "evil-winrm" || log_fail "evil-winrm"
fi

log_info "Instalando Wpscan..."
if gem list -i wpscan &> /dev/null; then
    log_ok "wpscan"
else
    sudo gem install wpscan &>/dev/null && log_ok "wpscan" || log_fail "wpscan"
fi

# =============================
# Compilaciones manuales / Go / repositorios
# =============================
log_info "Instalando enum4linux-ng..."
if [ -d "/opt/enum4linux-ng" ]; then
    sudo chmod +x /opt/enum4linux-ng/enum4linux-ng.py 2>/dev/null || true
    sudo ln -sf /opt/enum4linux-ng/enum4linux-ng.py /usr/local/bin/enum4linux-ng || true
    log_ok "enum4linux-ng"
else
    sudo git clone https://github.com/cddmp/enum4linux-ng /opt/enum4linux-ng &>/dev/null
    sudo chown -R "$USER:$USER" /opt/enum4linux-ng
    if [ -f "/opt/enum4linux-ng/enum4linux-ng.py" ]; then
        sudo chmod +x /opt/enum4linux-ng/enum4linux-ng.py
        sudo ln -sf /opt/enum4linux-ng/enum4linux-ng.py /usr/local/bin/enum4linux-ng
        log_ok "enum4linux-ng"
    else
        log_fail "enum4linux-ng"
    fi
fi

log_info "Instalando Naabu vía Go..."
if command -v naabu &>/dev/null; then
    log_ok "Naabu"
else
    go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest &>/dev/null && log_ok "Naabu" || log_fail "Naabu"
fi

log_info "Instalando Subfinder vía Go..."
if command -v subfinder &>/dev/null; then
    log_ok "Subfinder"
else
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &>/dev/null && log_ok "Subfinder" || log_fail "Subfinder"
fi

log_info "Compilando e instalando Kerbrute..."
if command -v kerbrute &>/dev/null; then
    log_ok "Kerbrute"
else
    rm -rf /tmp/kerbrute
    git clone https://github.com/ropnop/kerbrute.git /tmp/kerbrute &>/dev/null
    cd /tmp/kerbrute
    make linux &>/dev/null
    if [ -f "/tmp/kerbrute/dist/kerbrute_linux_amd64" ]; then
        sudo cp /tmp/kerbrute/dist/kerbrute_linux_amd64 /usr/bin/kerbrute
        sudo chmod +x /usr/bin/kerbrute
        log_ok "Kerbrute"
    else
        log_fail "Kerbrute"
    fi
    cd ~
    rm -rf /tmp/kerbrute
fi

# =============================
# SecLists + Rockyou
# =============================
WORDLISTS_DIR="/usr/share/wordlists"
SECLISTS_DIR="$WORDLISTS_DIR/SecLists"
ROCKYOU_PATH="$WORDLISTS_DIR/rockyou.txt"

sudo mkdir -p "$WORDLISTS_DIR"

log_info "Instalando SecLists (Método rápido)..."
if [ -d "$SECLISTS_DIR" ] && [ "$(ls -A $SECLISTS_DIR 2>/dev/null)" ]; then
    log_ok "SecLists"
else
    sudo rm -rf "$SECLISTS_DIR" 2>/dev/null || true
    sudo mkdir -p "$SECLISTS_DIR"
    if wget -q https://github.com/danielmiessler/SecLists/archive/master.tar.gz -O /tmp/seclists.tar.gz; then
        sudo tar -xzf /tmp/seclists.tar.gz -C "$SECLISTS_DIR" --strip-components=1
        rm -f /tmp/seclists.tar.gz
        log_ok "SecLists"
    else
        log_fail "SecLists"
    fi
fi

log_info "Verificando rockyou.txt..."
if [ -f "$ROCKYOU_PATH" ]; then
    log_ok "rockyou.txt"
else
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
    curl -s https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
    chmod +x /tmp/msfinstall
    sudo /tmp/msfinstall && log_ok "Metasploit" || log_fail "Metasploit"
    rm -f /tmp/msfinstall
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
alias wireshark='sudo wireshark'
alias aconnect='adb connect 127.0.0.1:5555'
alias scr='scrcpy --max-fps 30 --turn-screen-off'
EOF
fi
log_ok "alias añadidos"

# =============================
# EXPLOIT-DB / SEARCHSPLOIT
# =============================
log_info "Instalando Exploit-DB (Searchsploit)..."
REPOS=( "exploitdb" "exploitdb-papers" )
for repo in "${REPOS[@]}"; do
    INSTALL_DIR="/opt/$repo"
    if [ -d "$INSTALL_DIR" ]; then
        cd "$INSTALL_DIR" && sudo git pull &>/dev/null || true
    else
        sudo git clone --depth 1 "https://gitlab.com/exploit-database/$repo.git" "$INSTALL_DIR" &>/dev/null
    fi
    sudo chown -R "$USER:$USER" "$INSTALL_DIR"
done
if [ ! -L "/usr/local/bin/searchsploit" ]; then
    sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit
fi

# Docker dependencias pre-bloodhound
install_if_missing docker docker.io
install_if_missing "docker compose" docker-compose-v2
sudo systemctl start docker || true

# =============================
# TABLA DE VERIFICACIÓN PRE-BLOODHOUND
# =============================
TERM_WIDTH=$(tput cols)
[ "$TERM_WIDTH" -lt 60 ] && TERM_WIDTH=60
BOX_WIDTH=60

print_border() {
    local padding=$(( (TERM_WIDTH - BOX_WIDTH) / 2 ))
    printf "%*s%b" "$padding" "" "$BLUE"
    printf '=%.0s' $(seq 1 $BOX_WIDTH)
    printf '%b\n' "$NC"
}

print_centered() {
    local text="$1"
    local color="${2:-$NC}"
    local padding=$(( (BOX_WIDTH - ${#text}) / 2 ))
    local margin=$(( (TERM_WIDTH - BOX_WIDTH) / 2 ))
    printf "%*s%b%*s%s%*s%b\n" "$margin" "" "$color" "$padding" "" "$text" "$padding" "" "$NC"
}

progress_bar() {
    local tool="$1"
    local display="$2"
    local duration=3
    local margin=$(( (TERM_WIDTH - BOX_WIDTH) / 2 ))

    if command -v "$tool" &> /dev/null || [ -f "/snap/bin/$tool" ] || [ -f "/usr/local/bin/$tool" ] || [ -d "/opt/$tool" ] || { [ "$tool" = "nxc" ] && command -v nxc &>/dev/null; } || { [ "$tool" = "impacket" ] && python3 -c "import impacket" &>/dev/null; }; then
        status="${GREEN}✔ OK${NC}"
    else
        status="${RED}✘ FAIL${NC}"
    fi

    sleep 0.005
    printf "%*s[+] %-22s : %b\n" "$margin" "" "$display" "$status"
}

clear
print_border
print_centered "🔍 VERIFICACIÓN DE ARSENAL ENTORNO BASE" "$BOLD$BLUE"
print_border

tools=(
    "gobuster Gobuster" "ffuf FFUF" "hashcat Hashcat" "john John" "nmap Nmap" 
    "wireshark Wireshark" "nikto Nikto" "sqlmap SQLMap" "tcpdump TCPDump" "hydra Hydra" 
    "adb ADB" "msfconsole Metasploit" "jq jq" "exiftool Exiftool" "whatweb Whatweb" 
    "aircrack-ng Aircrack-ng" "binwalk Binwalk" "evil-winrm Evil-WinRM" "wpscan Wpscan" 
    "sherlock Sherlock" "smbclient smbclient" "sqlite3 SQLite3" "java Java-JDK" 
    "psql PostgreSQL" "medusa Medusa" "scrcpy Scrcpy" "nxc NetExec" "impacket Impacket" 
    "feroxbuster Feroxbuster" "amass Amass" "subfinder Subfinder" "httpx Httpx" 
    "naabu Naabu" "kerbrute Kerbrute" "enum4linux-ng enum4linux-ng" "rustscan RustScan"
)

for t in "${tools[@]}"; do
    tool_name=$(echo $t | awk '{print $1}')
    display_name=$(echo $t | cut -d' ' -f2-)
    progress_bar "$tool_name" "$display_name"
done
print_border

# =============================
# DESPLIEGUE FINAL INTERACTIVO: BLOODHOUND CE
# =============================
echo -e "\n${YELLOW}${BOLD}[*] INICIANDO CONFIGURACIÓN FINAL DE BLOODHOUND CE (DOCKER)...${NC}"

if [ ! -f "/usr/local/bin/bloodhound-ce" ]; then
    rm -rf /tmp/bloodhound-cli*
    wget -q https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-linux-amd64.tar.gz -O /tmp/bloodhound-cli-linux-amd64.tar.gz
    tar -xzf /tmp/bloodhound-cli-linux-amd64.tar.gz -C /tmp/
    sudo mv /tmp/bloodhound-cli /usr/local/bin/bloodhound-ce
    sudo chmod +x /usr/local/bin/bloodhound-ce
    rm -f /tmp/bloodhound-cli-linux-amd64.tar.gz
fi

echo -e "${BLUE}[+] Desplegando infraestructura e imprimiendo accesos oficiales...${NC}\n"

sudo mkdir -p "$HOME/.config/bloodhound"
sudo chown -R "$USER:$USER" "$HOME/.config/bloodhound"

sudo bloodhound-ce install

# =============================
# DOCUMENTACIÓN DE COMANDOS SOLICITADOS
# =============================
echo -e "\n${BLUE}${BOLD}======================================================${NC}"
echo -e "${GREEN}${BOLD}      🛠️  GUÍA DE MANTENIMIENTO DE BLOODHOUND CE      ${NC}"
echo -e "${BLUE}${BOLD}======================================================${NC}"
echo -e "${BOLD}Para gestionar tus contenedores usa los siguientes comandos:${NC}"
echo -e "  ${YELLOW}sudo bloodhound-ce update${NC}   -> Sirve para actualizar los contenedores y las imágenes a la última versión."
echo -e "  ${YELLOW}sudo bloodhound-ce resetpwd${NC} -> Resetea la contraseña de administración del usuario 'admin' y genera una nueva."
echo -e "  ${YELLOW}sudo bloodhound-ce down${NC}     -> Apaga el servidor por completo para liberar recursos de tu máquina."
echo -e "  ${YELLOW}sudo bloodhound-ce up${NC}       -> Vuelve a encender tu servidor con los datos que tenías guardados."
echo -e "${BLUE}${BOLD}======================================================${NC}\n"

print_centered "¡Auditoría lista - Happy Hacking! ✔" "$BOLD$GREEN"
print_centered "Para usar Wireshark, Scrcpy o los alias ejecuta: source ~/.bashrc" "$BOLD$YELLOW"
print_border

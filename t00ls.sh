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
# LOGGING ESTÉTICO (Alineación Premium con prefijo [+])
# =============================
log_ok() { printf "[+] %-55s [%b✔ OK%b]\n" "$1" "${GREEN}${BOLD}" "${NC}"; }
log_fail() { printf "[+] %-55s [%b✘ FAIL%b]\n" "$1" "${RED}${BOLD}" "${NC}"; }
log_info() { printf "[+] %-55s [%b* INFO%b]\n" "$1" "${BLUE}" "${NC}"; }
log_warn() { printf "[+] %-55s [%b! WARN%b]\n" "$1" "${YELLOW}" "${NC}"; }

# =============================
# FUNCIONES AUXILIARES
# =============================
install_if_missing() {
    local cmd="$1"
    local pkg="$2"
    if command -v "$cmd" &> /dev/null || dpkg -s "$pkg" &> /dev/null; then
        log_ok "$pkg"
    else
        log_info "$pkg instalando..."
        sleep $DELAY
        if sudo apt install -y "$pkg" &>/dev/null; then
            log_ok "$pkg"
        else
            log_fail "$pkg"
            exit 1
        fi
    fi
    sleep $DELAY
}

# =============================
# MÓDULOS DE INSTALACIÓN
# =============================

install_base() {
    echo -e "\n${BLUE}${BOLD}--- [1] INSTALANDO ENTORNO BASE ---${NC}\n"
    log_info "Actualizando lista de paquetes..."
    sudo apt update -y &>/dev/null

    log_info "Instalando herramientas esenciales..."
    install_if_missing curl curl
    install_if_missing wget wget
    install_if_missing git git
    install_if_missing make build-essential
    install_if_missing gpg gnupg2
    install_if_missing unzip unzip
    install_if_missing jq jq
    install_if_missing exittool libimage-exiftool-perl

    log_info "Configurando variables de entorno..."
    if ! grep -q "# ====== ENVIROMENT PATHS ======" ~/.bashrc; then
        printf "\n# ====== ENVIROMENT PATHS ======\nexport PATH=\"\$HOME/.local/bin:\$HOME/go/bin:/opt/enum4linux-ng:\$PATH\"\nexport PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1\n" >> ~/.bashrc
    fi
    export PATH="$HOME/.local/bin:$HOME/go/bin:/opt/enum4linux-ng:$PATH"
    export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

    log_info "Instalando dependencias base de lenguajes..."
    sudo apt install -y pipx git rustc cargo build-essential python3-dev libffi-dev golang libpcap-dev python3-impacket &>/dev/null
    pipx ensurepath &>/dev/null
    hash -r
    
    install_if_missing java default-jdk
    install_if_missing psql postgresql
}

install_web() {
    echo -e "\n${BLUE}${BOLD}--- [2] INSTALANDO WEB HACKING ---${NC}\n"
    install_if_missing gobuster gobuster
    install_if_missing nikto nikto
    install_if_missing sqlmap sqlmap
    install_if_missing whatweb whatweb
    
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

    install_if_missing gem ruby-rubygems
    install_if_missing ruby-dev ruby-dev
    if gem list -i wpscan &> /dev/null; then
        log_ok "wpscan"
    else
        sudo gem install wpscan &>/dev/null && log_ok "wpscan" || log_fail "wpscan"
    fi
}

install_ad() {
    echo -e "\n${BLUE}${BOLD}--- [3] INSTALANDO ACTIVE DIRECTORY ---${NC}\n"
    install_if_missing smbclient smbclient

    install_if_missing gem ruby-rubygems
    install_if_missing ruby-dev ruby-dev
    if gem list -i evil-winrm &> /dev/null; then
        log_ok "evil-winrm"
    else
        sudo gem install evil-winrm &>/dev/null && log_ok "evil-winrm" || log_fail "evil-winrm"
    fi

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

    if command -v kerbrute &>/dev/null; then
        log_ok "Kerbrute"
    else
        rm -rf /tmp/kerbrute
        git clone https://github.com/ropnop/kerbrute.git /tmp/kerbrute &>/dev/null
        cd /tmp/kerbrute && make linux &>/dev/null
        if [ -f "/tmp/kerbrute/dist/kerbrute_linux_amd64" ]; then
            sudo cp /tmp/kerbrute/dist/kerbrute_linux_amd64 /usr/bin/kerbrute
            sudo chmod +x /usr/bin/kerbrute
            log_ok "Kerbrute"
        else
            log_fail "Kerbrute"
        fi
        cd ~ && rm -rf /tmp/kerbrute
    fi
}

install_recon() {
    echo -e "\n${BLUE}${BOLD}--- [4] INSTALANDO RECONOCIMIENTO ---${NC}\n"
    install_if_missing nmap nmap
    install_if_missing ifconfig net-tools
    install_if_missing tcpdump tcpdump
    install_if_missing wireshark wireshark
    install_if_missing aircrack-ng aircrack-ng

    sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure wireshark-common &>/dev/null || true
    if [ -f /usr/bin/dumpcap ]; then
        sudo chown root:root /usr/bin/dumpcap
        sudo chmod 700 /usr/bin/dumpcap
    fi

    for snap_pkg in rustscan feroxbuster amass httpx; do
        if command -v "$snap_pkg" &> /dev/null || [ -f "/snap/bin/$snap_pkg" ]; then
            log_ok "$snap_pkg"
        else
            sudo snap install "$snap_pkg" &>/dev/null && log_ok "$snap_pkg" || log_fail "$snap_pkg"
        fi
    done

    if command -v naabu &>/dev/null; then log_ok "Naabu"; else go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest &>/dev/null && log_ok "Naabu" || log_fail "Naabu"; fi
    if command -v subfinder &>/dev/null; then log_ok "Subfinder"; else go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &>/dev/null && log_ok "Subfinder" || log_fail "Subfinder"; fi

    if command -v nxc &>/dev/null; then log_ok "NetExec"; else pipx install git+https://github.com/Pennyw0rth/NetExec &>/dev/null && log_ok "NetExec" || log_fail "NetExec"; fi
}

install_crypto() {
    echo -e "\n${BLUE}${BOLD}--- [5] INSTALANDO FUERZA BRUTA ---${NC}\n"
    install_if_missing hashcat hashcat
    install_if_missing john john
    install_if_missing hydra hydra
    install_if_missing medusa medusa
    install_if_missing sqlite3 sqlite3
}

install_android() {
    echo -e "\n${BLUE}${BOLD}--- [6] INSTALANDO ANDROID ENVIRONMENT ---${NC}\n"
    install_if_missing adb adb

    sudo apt install -y ffmpeg libsdl3-0 libusb-1.0-0 wget gcc git pkg-config meson ninja-build libsdl3-dev \
                        libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev libswresample-dev libusb-1.0-0-dev libv4l-dev &>/dev/null

    if command -v scrcpy &>/dev/null; then
        log_ok "Scrcpy"
    else
        rm -rf /tmp/scrcpy
        git clone https://github.com/Genymobile/scrcpy /tmp/scrcpy &>/dev/null
        cd /tmp/scrcpy && ./install_release.sh &>/dev/null
        cd ~ && rm -rf /tmp/scrcpy
        log_ok "Scrcpy (Compilado)"
    fi
}

install_osint() {
    echo -e "\n${BLUE}${BOLD}--- [7] INSTALANDO OSINT & FORENSE ---${NC}\n"
    install_if_missing binwalk binwalk

    if command -v sherlock &>/dev/null; then
        log_ok "Sherlock"
    else
        pipx install sherlock-project &>/dev/null && log_ok "Sherlock" || log_fail "Sherlock"
    fi

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
    log_ok "Searchsploit"
}

install_wordlists() {
    echo -e "\n${BLUE}${BOLD}--- [8] CONFIGURANDO WORDLISTS Y ALIAS ---${NC}\n"
    WORDLISTS_DIR="/usr/share/wordlists"
    SECLISTS_DIR="$WORDLISTS_DIR/SecLists"
    ROCKYOU_PATH="$WORDLISTS_DIR/rockyou.txt"
    sudo mkdir -p "$WORDLISTS_DIR"

    if [ -d "$SECLISTS_DIR" ] && [ "$(ls -A $SECLISTS_DIR 2>/dev/null)" ]; then
        log_ok "SecLists"
    else
        sudo rm -rf "$SECLISTS_DIR" 2>/dev/null || true
        sudo mkdir -p "$SECLISTS_DIR"
        if wget -q https://github.com/danielmiessler/SecLists/archive/master.tar.gz -O /tmp/seclists.tar.gz; then
            sudo tar -xzf /tmp/seclists.tar.gz -C "$SECLISTS_DIR" --strip-components=1
            rm -f /tmp/seclists.tar.gz && log_ok "SecLists"
        else
            log_fail "SecLists"
        fi
    fi

    if [ -f "$ROCKYOU_PATH" ]; then
        log_ok "rockyou.txt"
    else
        wget -q https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -O /tmp/rockyou.txt
        sudo mv /tmp/rockyou.txt "$ROCKYOU_PATH"
        log_ok "rockyou.txt"
    fi
    
    if ! grep -q "# ====== HACKING ALIASES ======" ~/.bashrc; then
        printf "\n# ====== HACKING ALIASES ======\nalias rockyou='%s'\nalias seclists='cd %s'\nalias msf='msfconsole'\nalias wireshark='sudo wireshark'\nalias aconnect='adb connect 127.0.0.1:5555'\nalias scr='scrcpy --max-fps 30 --turn-screen-off'\n" "$ROCKYOU_PATH" "$SECLISTS_DIR" >> ~/.bashrc
    fi
    log_ok "Aliases inyectados"
}

install_metasploit() {
    echo -e "\n${BLUE}${BOLD}--- [9] INSTALANDO METASPLOIT ---${NC}\n"
    if command -v msfconsole &> /dev/null; then
        log_ok "Metasploit"
    else
        curl -s https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
        chmod +x /tmp/msfinstall
        sudo /tmp/msfinstall &>/dev/null && log_ok "Metasploit" || log_fail "Metasploit"
        rm -f /tmp/msfinstall
    fi
}

install_burpsuite() {
    echo -e "\n${BLUE}${BOLD}--- [10] INSTALANDO BURP SUITE PRO (AUT0BURP) ---${NC}\n"
    log_info "Preparando directorio y clonando Aut0Burp..."
    rm -rf /tmp/aut0burp
    
    if git clone https://github.com/kr1pt0n/aut0burp.git /tmp/aut0burp &>/dev/null; then
        cd /tmp/aut0burp
        chmod +x aut0burp.py
        log_info "Iniciando script de instalación interactivo..."
        echo -e "\n========================================================"
        python3 aut0burp.py
        echo -e "========================================================\n"
        cd ~
        rm -rf /tmp/aut0burp
        log_ok "Burp Suite CE (Aut0Burp)"
    else
        log_fail "Burp Suite CE (Aut0Burp)"
    fi
}

install_bloodhound() {
    echo -e "\n${BLUE}${BOLD}--- [11] DESPLEGANDO BLOODHOUND CE ---${NC}\n"
    install_if_missing docker docker.io
    install_if_missing "docker compose" docker-compose-v2
    echo "" # Espacio solicitado después de docker-compose-v2 OK
    
    sudo systemctl start docker || true

    if [ ! -f "/usr/local/bin/bloodhound-ce" ]; then
        rm -rf /tmp/bloodhound-cli*
        wget -q https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-linux-amd64.tar.gz -O /tmp/bloodhound-cli-linux-amd64.tar.gz
        tar -xzf /tmp/bloodhound-cli-linux-amd64.tar.gz -C /tmp/
        sudo mv /tmp/bloodhound-cli /usr/local/bin/bloodhound-ce
        sudo chmod +x /usr/local/bin/bloodhound-ce
        rm -f /tmp/bloodhound-cli-linux-amd64.tar.gz
    fi

    sudo mkdir -p "$HOME/.config/bloodhound"
    sudo chown -R "$USER:$USER" "$HOME/.config/bloodhound"
    sudo bloodhound-ce install
}

# =============================
# INTERFAZ DE MENÚ INTERACTIVO
# =============================
clear
echo -e "${GREEN}"
echo "     /\\                 /\\ "
echo "    / \\'._   (\\_/)   _.'/ \\ "
echo "   /_.''._'--('.')--'_.''._\\ "
echo "   | \\_ / \`;=/ \" \\=;\` \\ _/ | "
echo "    \\/ \`\\__|\`\\___/\`|__/\`  \\/ "
echo "         \\(/|\\)/       "
echo "         ubunt00l\$"
echo -e "${NC}"

echo -e "${BOLD}${BLUE}Seleccione los módulos que desea instalar (separados por comas):${NC}\n"
echo -e "  [1]  Entorno Base"
echo -e "  [2]  Web Hacking"
echo -e "  [3]  Active Directory"
echo -e "  [4]  Reconocimiento"
echo -e "  [5]  Fuerza Bruta"
echo -e "  [6]  Android"
echo -e "  [7]  OSINT & Forense"
echo -e "  [8]  Wordlists & Aliases"
echo -e "  [9]  Metasploit"
echo -e "  [10] Burp Suite CE (Aut0Burp)"
echo -e "  [11] BloodHound CE"
echo -e "  [12] ${BOLD}Instalar Arsenal Completo (Todo)${NC}"
echo -e "  [0]  Salir\n"

read -p "Ejemplo (1,2,10): " input_options

input_options=$(echo "$input_options" | tr -d ' ')

if [ "$input_options" = "0" ] || [ -z "$input_options" ]; then
    echo -e "${YELLOW}[!] Saliendo sin realizar cambios.${NC}"
    exit 0
fi

# =============================
# PROCESAMIENTO MÚLTIPLE (LÓGICA PARSER)
# =============================
IFS=',' read -ra ADDR <<< "$input_options"

for option in "${ADDR[@]}"; do
    case $option in
        1)  install_base ;;
        2)  install_web ;;
        3)  install_ad ;;
        4)  install_recon ;;
        5)  install_crypto ;;
        6)  install_android ;;
        7)  install_osint ;;
        8)  install_wordlists ;;
        9)  install_metasploit ;;
        10) install_burpsuite ;;
        11) install_bloodhound ;;
        12) 
            install_base
            install_web
            install_ad
            install_recon
            install_crypto
            install_android
            install_osint
            install_wordlists
            install_metasploit
            install_burpsuite
            install_bloodhound
            break
            ;;
        *)  log_warn "Opción no reconocida: $option" ;;
    esac
done

# =============================
# CIERRE Y DOCUMENTACIÓN
# =============================
if [[ " ${ADDR[*]} " =~ " 11 " || " ${ADDR[*]} " =~ " 12 " ]]; then
    echo -e "\n${BLUE}${BOLD}==================================================================${NC}"
    echo -e "${GREEN}${BOLD}                  🛠️  GUÍA DE MANTENIMIENTO DE BLOODHOUND CE      ${NC}"
    echo -e "${BLUE}${BOLD}==================================================================${NC}"
    echo -e "  ${YELLOW}sudo bloodhound-ce update${NC}   -> Actualizar contenedores e imágenes."
    echo -e "  ${YELLOW}sudo bloodhound-ce resetpwd${NC} -> Restablecer contraseña del usuario 'admin'."
    echo -e "  ${YELLOW}sudo bloodhound-ce down${NC}     -> Apagar el servidor y liberar memoria RAM."
    echo -e "  ${YELLOW}sudo bloodhound-ce up${NC}       -> Levantar el entorno con datos guardados."
    echo -e "${BLUE}${BOLD}==================================================================${NC}"
fi

echo -e "\n${GREEN}${BOLD}[✔] ¡Auditoría modular lista!${NC}"
echo -e "${YELLOW}${BOLD}[!] Para aplicar los cambios de entorno y aliases ejecuta: source ~/.bashrc${NC}"
echo -e "${BLUE}${BOLD}==================================================================${NC}\n"

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

# LOGGING ESTÉTICO

# =============================

log_ok() { echo -e "[✔ OK] ${GREEN}${BOLD}$1${NC}"; }

log_fail() { echo -e "[✘ FAIL] ${RED}${BOLD}$1${NC}"; }

log_info() { echo -e "\n[i] ${BLUE}${BOLD}Procesando: $1...${NC}\n"; }

log_warn() { echo -e "[!] ${YELLOW}${BOLD}$1${NC}"; }



install_if_missing() {

    local cmd="$1"

    local pkg="$2"

    if command -v "$cmd" &> /dev/null || dpkg -s "$pkg" &> /dev/null; then

        log_ok "$pkg ya está instalado."

    else

        log_info "Instalando paquete APT: $pkg"

        if sudo apt-get install -y "$pkg"; then

            log_ok "$pkg instalado correctamente."

        else

            log_fail "Error al instalar $pkg."

            exit 1

        fi

    fi

    sleep $DELAY

}



# =============================

# MÓDULOS DE INSTALACIÓN

# =============================



install_base() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [1] INSTALANDO ENTORNO BASE ---------${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    

    log_info "Actualizando lista de paquetes (apt update)"

    sudo apt-get update -y



    install_if_missing curl curl

    install_if_missing wget wget

    install_if_missing git git

    install_if_missing make build-essential

    install_if_missing gpg gnupg2

    install_if_missing unzip unzip

    install_if_missing jq jq

    install_if_missing exiftool libimage-exiftool-perl



    log_info "Configurando variables de entorno (.bashrc)"

    if ! grep -q "# ====== ENVIROMENT PATHS ======" ~/.bashrc; then

        printf "\n# ====== ENVIROMENT PATHS ======\nexport PATH=\"\$HOME/.local/bin:\$HOME/go/bin:/opt/enum4linux-ng:\$PATH\"\nexport PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1\n" >> ~/.bashrc

    fi

    export PATH="$HOME/.local/bin:$HOME/go/bin:/opt/enum4linux-ng:$PATH"

    export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1



    log_info "Instalando dependencias de lenguajes (Go, Rust, Python)"

    sudo apt-get install -y pipx git rustc cargo python3-dev libffi-dev golang libpcap-dev python3-impacket

    

    pipx ensurepath &>/dev/null

    hash -r

    

    install_if_missing java default-jdk

    install_if_missing psql postgresql

}



install_web() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [2] INSTALANDO WEB HACKING ----------${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    install_if_missing gobuster gobuster

    install_if_missing nikto nikto

    install_if_missing sqlmap sqlmap

    install_if_missing whatweb whatweb

    

    if command -v ffuf &> /dev/null; then

        log_ok "ffuf ya está instalado."

    else

        log_info "Descargando e instalando ffuf desde GitHub"

        FFUF_VERSION=$(curl -s https://api.github.com/repos/ffuf/ffuf/releases/latest | jq -r '.tag_name' | sed 's/v//')

        wget "https://github.com/ffuf/ffuf/releases/download/v${FFUF_VERSION}/ffuf_${FFUF_VERSION}_linux_amd64.tar.gz" -O /tmp/ffuf.tar.gz

        tar -xzf /tmp/ffuf.tar.gz -C /tmp/

        sudo mv /tmp/ffuf /usr/local/bin/ffuf

        rm -f /tmp/ffuf.tar.gz

        [ -x /usr/local/bin/ffuf ] && log_ok "ffuf configurado." || log_fail "ffuf falló."

    fi



    install_if_missing gem ruby-rubygems

    install_if_missing ruby-dev ruby-dev

    if gem list -i wpscan &> /dev/null; then

        log_ok "wpscan ya está instalado."

    else

        log_info "Instalando gema wpscan (Ruby)"

        sudo gem install wpscan && log_ok "wpscan instalado." || log_fail "wpscan falló."

    fi

}



install_ad() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [3] INSTALANDO ACTIVE DIRECTORY -----${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    install_if_missing smbclient smbclient



    install_if_missing gem ruby-rubygems

    install_if_missing ruby-dev ruby-dev

    if gem list -i evil-winrm &> /dev/null; then

        log_ok "evil-winrm ya está instalado."

    else

        log_info "Instalando gema evil-winrm (Ruby)"

        sudo gem install evil-winrm && log_ok "evil-winrm instalado." || log_fail "evil-winrm falló."

    fi



    if [ -d "/opt/enum4linux-ng" ]; then

        sudo chmod +x /opt/enum4linux-ng/enum4linux-ng.py 2>/dev/null || true

        sudo ln -sf /opt/enum4linux-ng/enum4linux-ng.py /usr/local/bin/enum4linux-ng || true

        log_ok "enum4linux-ng ya configurado."

    else

        log_info "Clonando enum4linux-ng en /opt"

        sudo git clone https://github.com/cddmp/enum4linux-ng /opt/enum4linux-ng

        sudo chown -R "$USER:$USER" /opt/enum4linux-ng

        sudo chmod +x /opt/enum4linux-ng/enum4linux-ng.py

        sudo ln -sf /opt/enum4linux-ng/enum4linux-ng.py /usr/local/bin/enum4linux-ng

        log_ok "enum4linux-ng listo."

    fi



    if command -v kerbrute &>/dev/null; then

        log_ok "Kerbrute ya está instalado."

    else

        log_info "Compilando Kerbrute desde Go source"

        rm -rf /tmp/kerbrute

        git clone https://github.com/ropnop/kerbrute.git /tmp/kerbrute

        cd /tmp/kerbrute && make linux

        sudo cp dist/kerbrute_linux_amd64 /usr/bin/kerbrute

        sudo chmod +x /usr/bin/kerbrute

        cd ~ && rm -rf /tmp/kerbrute

        log_ok "Kerbrute compilado e instalado."

    fi

}



install_recon() {
    echo -e "\n${BLUE}${BOLD}=========================================${NC}"
    echo -e "${BLUE}${BOLD}--- [4] INSTALANDO RECONOCIMIENTO -------${NC}"
    echo -e "${BLUE}${BOLD}=========================================${NC}"
    install_if_missing nmap nmap
    install_if_missing ifconfig net-tools
    install_if_missing tcpdump tcpdump

    # [FIX 1] Limpiar posibles residuos de grupos viejos conflictivos
    sudo groupdel wireshark 2>/dev/null || true

    # [FIX 2] Pre-configurar debconf en "SÍ" para que la instalación NO sea interactiva
    echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections

    install_if_missing wireshark wireshark
    install_if_missing aircrack-ng aircrack-ng

    # [FIX 3] Forzar la reconfiguración limpia sin ventanas emergentes
    sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure wireshark-common

    # [FIX 4] Asignar correctamente los privilegios y las Linux Capabilities a dumpcap
    if [ -f /usr/bin/dumpcap ]; then
        sudo chown root:wireshark /usr/bin/dumpcap
        sudo chmod 750 /usr/bin/dumpcap
        sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
    fi

    # [FIX 5] Añadir automáticamente al usuario del script al grupo para evitar que use sudo
    sudo usermod -aG wireshark "$USER"
    log_ok "Wireshark configurado sin interacción para el usuario: $USER"


    for snap_pkg in rustscan feroxbuster amass httpx; do

        if command -v "$snap_pkg" &> /dev/null || [ -f "/snap/bin/$snap_pkg" ]; then

            log_ok "Snap: $snap_pkg ya está instalado."

        else

            log_info "Instalando Snap de forma pública: $snap_pkg"

            sudo snap install "$snap_pkg" && log_ok "Snap $snap_pkg listo." || log_fail "Snap $snap_pkg falló."

        fi

    done



    if command -v naabu &>/dev/null; then log_ok "Naabu ya existe."; else log_info "Instalando Naabu por Go..."; go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest && log_ok "Naabu listo."; fi

    if command -v subfinder &>/dev/null; then log_ok "Subfinder ya existe."; else log_info "Instalando Subfinder por Go..."; go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && log_ok "Subfinder listo."; fi



    if command -v nxc &>/dev/null; then log_ok "NetExec ya existe."; else log_info "Instalando NetExec vía Pipx (Python)..."; pipx install git+https://github.com/Pennyw0rth/NetExec && log_ok "NetExec listo."; fi

}



install_crypto() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [5] INSTALANDO FUERZA BRUTA ---------${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    install_if_missing hashcat hashcat

    install_if_missing john john

    install_if_missing hydra hydra

    install_if_missing medusa medusa

    install_if_missing sqlite3 sqlite3

}



install_android() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [6] INSTALANDO ANDROID ENVIRONMENT --${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    install_if_missing adb adb



    log_info "Instalando dependencias pesadas de Scrcpy (Multimedia/Compilación)"

    sudo apt-get install -y ffmpeg libsdl3-0 libusb-1.0-0 wget gcc git pkg-config meson ninja-build libsdl3-dev libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev libswresample-dev libusb-1.0-0-dev libv4l-dev



    if command -v scrcpy &>/dev/null; then

        log_ok "Scrcpy ya está instalado."

    else

        log_info "Clonando y compilando Scrcpy (Genymobile)"

        rm -rf /tmp/scrcpy

        git clone https://github.com/Genymobile/scrcpy /tmp/scrcpy

        cd /tmp/scrcpy && ./install_release.sh

        cd ~ && rm -rf /tmp/scrcpy

        log_ok "Scrcpy compilado de forma nativa."

    fi

}



install_osint() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [7] INSTALANDO OSINT & FORENSE ------${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    install_if_missing binwalk binwalk



    if command -v sherlock &>/dev/null; then

        log_ok "Sherlock ya existe."

    else

        log_info "Instalando Sherlock por Pipx"

        pipx install sherlock-project && log_ok "Sherlock listo." || log_fail "Sherlock falló."

    fi



    REPOS=( "exploitdb" "exploitdb-papers" )

    for repo in "${REPOS[@]}"; do

        INSTALL_DIR="/opt/$repo"

        if [ -d "$INSTALL_DIR" ]; then

            log_info "Actualizando base de datos local de: $repo"

            cd "$INSTALL_DIR" && sudo git pull || true

        else

            log_info "Clonando base de datos: $repo en /opt"

            sudo git clone --depth 1 "https://gitlab.com/exploit-database/$repo.git" "$INSTALL_DIR"

        fi

        sudo chown -R "$USER:$USER" "$INSTALL_DIR"

    done

    if [ ! -L "/usr/local/bin/searchsploit" ]; then

        sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit

    fi

    log_ok "Searchsploit enlazado en el sistema."

}



install_wordlists() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [8] CONFIGURANDO WORDLISTS Y ALIAS --${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    WORDLISTS_DIR="/usr/share/wordlists"

    SECLISTS_DIR="$WORDLISTS_DIR/SecLists"

    ROCKYOU_PATH="$WORDLISTS_DIR/rockyou.txt"

    sudo mkdir -p "$WORDLISTS_DIR"



    if [ -d "$SECLISTS_DIR" ] && [ "$(ls -A $SECLISTS_DIR 2>/dev/null)" ]; then

        log_ok "SecLists ya descargado."

    else

        log_info "Descargando SecLists (danielmiessler) completo..."

        sudo rm -rf "$SECLISTS_DIR" 2>/dev/null || true

        sudo mkdir -p "$SECLISTS_DIR"

        wget https://github.com/danielmiessler/SecLists/archive/master.tar.gz -O /tmp/seclists.tar.gz

        log_info "Extrayendo SecLists en /usr/share/wordlists..."

        sudo tar -xzf /tmp/seclists.tar.gz -C "$SECLISTS_DIR" --strip-components=1

        rm -f /tmp/seclists.tar.gz && log_ok "SecLists configurado."

    fi



    if [ -f "$ROCKYOU_PATH" ]; then

        log_ok "rockyou.txt ya existe."

    else

        log_info "Descargando diccionario rockyou.txt original..."

        wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -O /tmp/rockyou.txt

        sudo mv /tmp/rockyou.txt "$ROCKYOU_PATH"

        log_ok "rockyou.txt ubicado en su ruta."

    fi

    

    if ! grep -q "# ====== HACKING ALIASES ======" ~/.bashrc; then

        printf "\n# ====== HACKING ALIASES ======\nalias rockyou='%s'\nalias seclists='cd %s'\nalias msf='msfconsole'\nalias wireshark='sudo wireshark'\nalias aconnect='adb connect 127.0.0.1:5555'\nalias scr='scrcpy --max-fps 30 --turn-screen-off'\n" "$ROCKYOU_PATH" "$SECLISTS_DIR" >> ~/.bashrc

    fi

    log_ok "Aliases guardados en tu .bashrc"

}



install_metasploit() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [9] INSTALANDO METASPLOIT -----------${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    if command -v msfconsole &> /dev/null; then

        log_ok "Metasploit Framework ya instalado."

    else

        log_info "Ejecutando instalador oficial de Rapid7 (Metasploit)..."

        curl -s https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall

        chmod +x /tmp/msfinstall

        sudo /tmp/msfinstall

        rm -f /tmp/msfinstall

        log_ok "Metasploit Framework listo."

    fi

}



install_burpsuite() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [10] INSTALANDO BURP SUITE (AUT0BURP)${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    log_info "Clonando Aut0Burp en directorio temporal"

    rm -rf /tmp/aut0burp

    

    if git clone https://github.com/kr1pt0n/aut0burp.git /tmp/aut0burp; then

        cd /tmp/aut0burp

        chmod +x aut0burp.py

        log_info "Lanzando instalador interactivo de Burp Suite..."

        python3 aut0burp.py

        cd ~

        rm -rf /tmp/aut0burp

        log_ok "Módulo Aut0Burp procesado."

    else

        log_fail "No se pudo clonar Aut0Burp."

    fi

}



install_bloodhound() {

    echo -e "\n${BLUE}${BOLD}=========================================${NC}"

    echo -e "${BLUE}${BOLD}--- [11] DESPLEGANDO BLOODHOUND CE ------${NC}"

    echo -e "${BLUE}${BOLD}=========================================${NC}"

    

    # Aquí verás de forma interactiva toda la instalación de Docker

    install_if_missing docker docker.io

    install_if_missing "docker compose" docker-compose-v2

    

    log_info "Iniciando servicio de Docker daemon"

    sudo systemctl start docker || true



    if [ ! -f "/usr/local/bin/bloodhound-ce" ]; then

        log_info "Descargando binario oficial de Bloodhound CLI..."

        rm -rf /tmp/bloodhound-cli*

        wget https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-linux-amd64.tar.gz -O /tmp/bloodhound-cli-linux-amd64.tar.gz

        tar -xzf /tmp/bloodhound-cli-linux-amd64.tar.gz -C /tmp/

        sudo mv /tmp/bloodhound-cli /usr/local/bin/bloodhound-ce

        sudo chmod +x /usr/local/bin/bloodhound-ce

        rm -f /tmp/bloodhound-cli-linux-amd64.tar.gz

    fi



    sudo mkdir -p "$HOME/.config/bloodhound"

    sudo chown -R "$USER:$USER" "$HOME/.config/bloodhound"

    

    log_info "Lanzando Docker Compose para Bloodhound CE (Descargando imágenes PostgreSQL y Neo4j en vivo)"

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

echo "         ubunt00l\$ by kr1pt0n"

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

# PROCESAMIENTO MÚLTIPLE

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

    echo -e "\n${BLUE}${BOLD}============================================================================${NC}"

    echo -e "${GREEN}${BOLD}                  🛠️  GUÍA DE MANTENIMIENTO DE BLOODHOUND CE      ${NC}"

    echo -e "${BLUE}${BOLD}============================================================================${NC}"

    echo -e "  ${YELLOW}sudo bloodhound-ce update${NC}   -> Actualizar contenedores e imágenes."

    echo -e "  ${YELLOW}sudo bloodhound-ce resetpwd${NC} -> Restablecer contraseña del usuario 'admin'."

    echo -e "  ${YELLOW}sudo bloodhound-ce down${NC}     -> Apagar el servidor y liberar memoria RAM."

    echo -e "  ${YELLOW}sudo bloodhound-ce up${NC}       -> Levantar el entorno con datos guardados."

    echo -e "${BLUE}${BOLD}============================================================================${NC}"

fi



echo -e "\n${GREEN}${BOLD}[✔] ¡Auditoría modular lista!${NC}"

echo -e "${YELLOW}${BOLD}[!] Para aplicar los cambios de entorno y aliases ejecuta: source ~/.bashrc${NC}"

echo -e "${BLUE}${BOLD}============================================================================${NC}\n"

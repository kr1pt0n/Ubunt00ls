#!/bin/bash
set -e

if [ "$EUID" -eq 0 ]; then
    echo "[X] No ejecutes como root. Usa: bash $0"
    exit 1
fi
sudo -v

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
NC="\e[0m"
DELAY=0.02

log_ok() { printf "[+] %-55s [%b✔ REMOVED%b]\n" "$1" "${GREEN}${BOLD}" "${NC}"; }
log_info() { printf "[+] %-55s [%b* PURGING%b]\n" "$1" "${BLUE}" "${NC}"; }

purge_pkg() {
    local pkg="$1"
    if dpkg -s "$pkg" &> /dev/null; then
        log_info "$pkg..."
        sudo apt remove --purge -y "$pkg" &>/dev/null
        log_ok "$pkg"
    else
        printf "[+] %-55s [%b- NOT FOUND%b]\n" "$pkg" "${YELLOW}" "${NC}"
    fi
    sleep $DELAY
}

purge_snap() {
    local snap_pkg="$1"
    if command -v "$snap_pkg" &> /dev/null || [ -f "/snap/bin/$snap_pkg" ]; then
        log_info "Snap: $snap_pkg..."
        sudo snap remove "$snap_pkg" &>/dev/null
        log_ok "Snap: $snap_pkg"
    fi
}

# ==========================================
# 1. HERRAMIENTAS DE PAQUETES (APT)
# ==========================================
echo -e "\n${RED}${BOLD}--- [1/5] ELIMINANDO BINARIOS Y PAQUETES APT ---${NC}\n"

APT_TOOLS=(gobuster nikto sqlmap whatweb smbclient aircrack-ng wireshark tcpdump nmap medusa hydra john hashcat adb binwalk metasploit-framework docker.io docker-compose-v2)

for tool in "${APT_TOOLS[@]}"; do
    purge_pkg "$tool"
done

# ==========================================
# 2. HERRAMIENTAS SNAP
# ==========================================
echo -e "\n${RED}${BOLD}--- [2/5] ELIMINANDO PAQUETES SNAP ---${NC}\n"
for snap_pkg in rustscan feroxbuster amass httpx; do
    purge_snap "$snap_pkg"
done

# ==========================================
# 3. GESTORES DE LENGUAJES (PIPX Y GEM)
# ==========================================
echo -e "\n${RED}${BOLD}--- [3/5] LIMPIANDO PIPX, GEM Y COMPILADOS ---${NC}\n"

# Desinstalar herramientas de PIPX antes de borrar el entorno
if command -v pipx &> /dev/null; then
    log_info "Removiendo herramientas de Python (NetExec/Sherlock)..."
    pipx uninstall netexec &>/dev/null || true
    pipx uninstall sherlock-project &>/dev/null || true
fi

# Desinstalar gemas de Ruby
if command -v gem &> /dev/null; then
    log_info "Removiendo gemas de Ruby (wpscan/evil-winrm)..."
    sudo gem uninstall -aIx wpscan evil-winrm &>/dev/null || true
fi

# Eliminar binarios sueltos en /usr/local/bin
sudo rm -f /usr/local/bin/ffuf /usr/local/bin/naabu /usr/local/bin/subfinder /usr/bin/kerbrute /usr/local/bin/scrcpy /usr/local/bin/bloodhound-ce /usr/local/bin/searchsploit 2>/dev/null || true

# ==========================================
# 4. LIMPIEZA DE DIRECTORIOS Y WORDLISTS
# ==========================================
echo -e "\n${RED}${BOLD}--- [4/5] BORRANDO DIRECTORIOS, CACHÉS Y WORDLISTS ---${NC}\n"

# Forzar la eliminación de la carpeta Go con SUDO (Evita el "Permiso denegado")
if [ -d "$HOME/go" ]; then
    log_info "Forzando borrado de módulos de Go (Modo Root)..."
    sudo rm -rf "$HOME/go"
    log_ok "Carpeta ~/go eliminada"
fi

# Borrar repositorios clonados en /opt
log_info "Limpiando directorios en /opt..."
sudo rm -rf /opt/exploitdb /opt/exploitdb-papers /opt/BurpSuitePro /opt/BurpSuite /opt/metasploit-framework /opt/enum4linux-ng 2>/dev/null || true

# Eliminar Wordlists de raíz
if [ -d "/usr/share/wordlists" ]; then
    log_info "Borrando SecLists y RockYou..."
    sudo rm -rf /usr/share/wordlists
    log_ok "Diccionarios eliminados"
fi

# Configuraciones ocultas del usuario
rm -rf ~/.local/share/pipx ~/.BurpSuite ~/.config/bloodhound 2>/dev/null || true

# ==========================================
# 5. CONFIGURACIONES DE ENTORNO
# ==========================================
echo -e "\n${RED}${BOLD}--- [5/5] LIMPIANDO VARIABLES DE ENTORNO ---${NC}\n"
sed -i '/# ====== HACKING ALIASES ======/,+6d' ~/.bashrc 2>/dev/null || true
sed -i '/# ====== ENVIROMENT PATHS ======/,+2d' ~/.bashrc 2>/dev/null || true
log_ok "Variables eliminadas de .bashrc"

echo -e "\n${GREEN}${BOLD}[✔] ¡TODO EL ARSENAL HA SIDO ELIMINADO POR COMPLETO!${NC}"
echo -e "${YELLOW}${BOLD}[!] Tu interfaz gráfica está a salvo. Ejecuta 'source ~/.bashrc' para finalizar.${NC}\n"
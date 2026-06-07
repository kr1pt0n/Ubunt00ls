# Ubunt00ls — 
# (Kit de herramientas de Pentesting para Ubuntu)
  ![Platform](https://img.shields.io/badge/Platform-Ubuntu%20Linux-E95420?logo=ubuntu&logoColor=white)
  ![Language](https://img.shields.io/badge/Language-Bash%20%2F%20Shell-4E9A06?logo=gnu-bash&logoColor=white)
  ![Environment](https://img.shields.io/badge/Focus-Pentesting%20%26%20Auditing-red?logo=linux&logoColor=white)
  ![License](https://img.shields.io/badge/License-MIT-green)

Script en **bash** que automatiza la instalación de un kit de herramientas de pentesting y networking en **Ubuntu/Debian**.

  **Aviso legal:** Usa estas herramientas únicamente en entornos propios o con permiso explícito. El uso indebido puede ser ilegal.

---
Instalación rápida
```bash 
git clone https://github.com/kr1pt0n/Ubunt00ls.git
cd Ubunt00ls
chmod +x t00ls.sh
./t00ls.sh
```

Ubuntu ofrece un equilibrio perfecto entre robustez, facilidad de uso y un ecosistema ampliamente soportado, lo que garantiza que el sistema operativo funcione de manera fluida y sin interrupciones, ideal para desarrollar y ejecutar herramientas sin complicaciones.

Por esta razón, les presento mi script de las herramientas mas usadas, totalmente compatibles para Ubuntu 24.04, aprovechando su estabilidad y la capacidad de mantener un entorno confiable para cualquier proyecto o tarea técnica.

Este script automatiza la instalación de varias herramientas desde sus fuentes oficiales, esenciales para pentesting en las ultimsa versiones LTS de Ubuntu (24.04 - 26.04). 
(Cumple con todas sus dependencias en Ubuntu 24.04 - 26.04)

# Herramientas de Hacking y Seguridad

## Web Hacking

| Herramienta     | Descripción                                           | Enlace Oficial                             |
| --------------- | ----------------------------------------------------- | ------------------------------------------ |
| **ffuf**        | Fuzzer rápido para descubrimiento de contenido web    | https://github.com/ffuf/ffuf               |
| **gobuster**    | Descubrimiento de directorios, archivos y subdominios | https://github.com/OJ/gobuster             |
| **feroxbuster** | Content discovery recursivo de alto rendimiento       | https://github.com/epi052/feroxbuster      |
| **nikto**       | Escáner de vulnerabilidades web                       | https://github.com/sullo/nikto             |
| **sqlmap**      | Detección y explotación de inyecciones SQL            | https://sqlmap.org                         |
| **whatweb**     | Fingerprinting de tecnologías web                     | https://github.com/urbanadventurer/WhatWeb |
| **wpscan**      | Escáner especializado para WordPress                  | https://github.com/wpscanteam/wpscan       |

---

## Redes y Análisis de Tráfico

| Herramienta   | Descripción                                                  | Enlace Oficial                            |
| ------------- | ------------------------------------------------------------ | ----------------------------------------- |
| **nmap**      | Escáner de red y puertos                                     | https://nmap.org                          |
| **rustscan**  | Escáner de puertos ultrarrápido basado en Rust               | https://github.com/RustScan/RustScan      |
| **naabu**     | Escáner moderno de puertos desarrollado por ProjectDiscovery | https://github.com/projectdiscovery/naabu |
| **wireshark** | Analizador gráfico de tráfico de red                         | https://www.wireshark.org                 |
| **tcpdump**   | Captura y análisis de tráfico desde consola                  | https://www.tcpdump.org                   |
| **net-tools** | Utilidades clásicas de red (ifconfig, netstat, arp, etc.)    | https://github.com/ecki/net-tools         |
| **httpx**     | Toolkit para validación y fingerprinting de hosts HTTP       | https://github.com/projectdiscovery/httpx |

---

## Active Directory & Pentesting Interno

| Herramienta       | Descripción                                                         | Enlace Oficial                            |
| ----------------- | ------------------------------------------------------------------- | ----------------------------------------- |
| **NetExec (NXC)** | Framework moderno para auditorías y enumeración en Active Directory | https://github.com/Pennyw0rth/NetExec     |
| **Impacket**      | Colección de herramientas y librerías para protocolos de red        | https://github.com/fortra/impacket        |
| **BloodHound CE** | Plataforma para análisis de relaciones y privilegios en AD          | https://github.com/SpecterOps/BloodHound  |
| **Kerbrute**      | Enumeración y validación de cuentas Kerberos                        | https://github.com/ropnop/kerbrute        |
| **enum4linux-ng** | Enumeración avanzada de servicios SMB y entornos Windows            | https://github.com/cddmp/enum4linux-ng    |
| **Evil-WinRM**    | Acceso remoto y administración de sistemas Windows mediante WinRM   | https://github.com/Hackplayers/evil-winrm |
| **smbclient**     | Cliente SMB para interacción con recursos compartidos               | https://www.samba.org                     |

---

## Reconocimiento y Enumeración

| Herramienta   | Descripción                                       | Enlace Oficial                                |
| ------------- | ------------------------------------------------- | --------------------------------------------- |
| **Amass**     | Enumeración de dominios e infraestructura externa | https://github.com/owasp-amass/amass          |
| **Subfinder** | Descubrimiento rápido de subdominios              | https://github.com/projectdiscovery/subfinder |
| **Gobuster**  | Enumeración de directorios, DNS y VHosts          | https://github.com/OJ/gobuster                |
| **Naabu**     | Descubrimiento rápido de puertos                  | https://github.com/projectdiscovery/naabu     |
| **Httpx**     | Validación y fingerprinting de servicios web      | https://github.com/projectdiscovery/httpx     |

---

## Cracking y Fuerza Bruta

| Herramienta         | Descripción                                  | Enlace Oficial                             |
| ------------------- | -------------------------------------------- | ------------------------------------------ |
| **Hashcat**         | Cracker avanzado de contraseñas mediante GPU | https://hashcat.net/hashcat                |
| **John the Ripper** | Cracker clásico de contraseñas               | https://www.openwall.com/john              |
| **Hydra**           | Fuerza bruta de servicios de autenticación   | https://github.com/vanhauser-thc/thc-hydra |
| **Medusa**          | Herramienta modular de fuerza bruta paralela | https://github.com/jmk-foofus/medusa       |

---

## WiFi Hacking

| Herramienta     | Descripción                        | Enlace Oficial              |
| --------------- | ---------------------------------- | --------------------------- |
| **Aircrack-ng** | Auditoría y cracking de redes WiFi | https://www.aircrack-ng.org |

---

## Android & Mobile

| Herramienta | Descripción                                           | Enlace Oficial                          |
| ----------- | ----------------------------------------------------- | --------------------------------------- |
| **ADB**     | Android Debug Bridge para administración y depuración | https://developer.android.com/tools/adb |
| **Scrcpy**  | Control y mirror de dispositivos Android vía USB/TCP  | https://github.com/Genymobile/scrcpy    |

---

## OSINT y Forense

| Herramienta  | Descripción                                   | Enlace Oficial                               |
| ------------ | --------------------------------------------- | -------------------------------------------- |
| **Sherlock** | Búsqueda de usuarios en múltiples plataformas | https://github.com/sherlock-project/sherlock |
| **Binwalk**  | Análisis y extracción de firmware             | https://github.com/ReFirmLabs/binwalk        |
| **ExifTool** | Análisis y modificación de metadatos          | https://exiftool.org                         |

---

## Explotación y Frameworks

| Herramienta                   | Descripción                                                    | Enlace Oficial             |
| ----------------------------- | -------------------------------------------------------------- | -------------------------- |
| **Metasploit Framework**      | Framework para pruebas de penetración y desarrollo de exploits | https://www.metasploit.com |
| **Exploit-DB / Searchsploit** | Base de datos local y buscador de exploits públicos            | https://www.exploit-db.com |

---

## Wordlists Incluidas

| Recurso         | Descripción                                                        |
| --------------- | ------------------------------------------------------------------ |
| **SecLists**    | Colección de diccionarios para fuzzing, enumeración y fuerza bruta |
| **RockYou.txt** | Diccionario clásico de contraseñas ampliamente utilizado           |

---

## Compatibilidad

* Ubuntu 24.04 LTS
* Ubuntu 26.04 LTS
* Arquitectura AMD64 (x86_64)

---

## Características

* Instalación automatizada e idempotente.
* Compatibilidad con Python 3.14.
* Integración con Pipx, Go, Snap y RubyGems.
* Despliegue opcional de BloodHound CE mediante Docker.
* Configuración automática de aliases y variables de entorno.
* Verificación visual del arsenal instalado.
* Descarga automática de SecLists y RockYou.
* Compilación optimizada de Scrcpy desde código fuente.






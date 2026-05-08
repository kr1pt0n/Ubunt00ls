# Ubunt00ls — Instalador de herramientas de Pentesting para Ubuntu
![N|Solid](https://www-file.huawei.com/admin/asset/v1/pro/view/501c611b6f92446c9a990b166d1ff90a.jpg)
Script en **bash** que automatiza la instalación de un kit de herramientas de pentesting y networking en **Ubuntu/Debian**.

>  **Aviso legal:** Usa estas herramientas únicamente en entornos propios o con permiso explícito. El uso indebido puede ser ilegal.

---

##  Requisitos

- Conexión a internet estable
- Usuario con privilegios `sudo`
- Paquetes base:
```bash
sudo apt update && sudo apt install -y git curl ca-certificates
```

Instalación rápida
```bash 
git clone https://github.com/kr1pt0n/Ubunt00ls.git
cd Ubunt00ls
chmod +x t00ls.sh
./t00ls.sh
```

Ubuntu ofrece un equilibrio perfecto entre robustez, facilidad de uso y un ecosistema ampliamente soportado, lo que garantiza que el sistema operativo funcione de manera fluida y sin interrupciones, ideal para desarrollar y ejecutar herramientas sin complicaciones.

Por esta razón, les presento mi script de las herramientas mas usadas, totalmente compatibles para Ubuntu 24.04, aprovechando su estabilidad y la capacidad de mantener un entorno confiable para cualquier proyecto o tarea técnica.

Este script automatiza la instalación de varias herramientas desde sus fuentes oficiales, esenciales para pentesting en la ultima versions LTS de Ubuntu (24.04). 
(Cumple con todas sus dependencias en Ubuntu 24.04)



## Herramientas de Hacking y Seguridad

### Web Hacking
| Herramienta     | Descripción | Enlace Oficial |
|-----------------|-------------|----------------|
| **wfuzz**       | Fuzzer para aplicaciones web | [WFuzz](https://github.com/xmendez/wfuzz) |
| **gobuster**    | Descubrimiento de directorios y subdominios | [Gobuster](https://github.com/OJ/gobuster) |
| **nikto**       | Escáner de vulnerabilidades web | [Nikto](https://github.com/sullo/nikto) |
| **sqlmap**      | Detección y explotación de inyecciones SQL | [SQLMap](https://sqlmap.org/) |
| **dirb**        | Búsqueda de directorios web por diccionario | [Dirb](https://gitlab.com/kalilinux/packages/dirb) |
| **whatweb**     | Fingerprinting de tecnologías web | [WhatWeb](https://github.com/urbanadventurer/WhatWeb) |

---

### Redes y Análisis de Tráfico
| Herramienta     | Descripción | Enlace Oficial |
|-----------------|-------------|----------------|
| **nmap**        | Escáner de red y puertos | [Nmap](https://nmap.org/) |
| **wireshark**   | Analizador gráfico de tráfico de red | [Wireshark](https://www.wireshark.org/) |
| **tcpdump**     | Captura y análisis de tráfico en consola | [Tcpdump](https://www.tcpdump.org/) |
| **net-tools**   | Utilidades clásicas de red (ifconfig, netstat, etc.) | [Net-tools](https://github.com/ecki/net-tools) |
| **dnsenum**     | Enumeración de información DNS | [Dnsenum](https://github.com/fwaeytens/dnsenum) |

---

### Cracking y Fuerza Bruta
| Herramienta     | Descripción | Enlace Oficial |
|-----------------|-------------|----------------|
| **hashcat**     | Cracker avanzado de contraseñas por GPU | [Hashcat](https://hashcat.net/hashcat/) |
| **john** (JTR)  | Cracker clásico de contraseñas | [John the Ripper](https://www.openwall.com/john/) |
| **hydra**       | Fuerza bruta de servicios de autenticación | [Hydra](https://github.com/vanhauser-thc/thc-hydra) |

---

### WiFi Hacking
| Herramienta     | Descripción | Enlace Oficial |
|-----------------|-------------|----------------|
| **aircrack-ng** | Cracking de WiFi (WEP/WPA/WPA2) | [Aircrack-ng](https://www.aircrack-ng.org/) |
| **hcxtools**    | Herramientas para auditorías de redes WiFi | [hcxtools](https://github.com/ZerBea/hcxtools) |
| **hcxdumptool** | Captura avanzada de handshakes WiFi | [hcxdumptool](https://github.com/ZerBea/hcxdumptool) |

---

### Android & Mobile
| Herramienta     | Descripción | Enlace Oficial |
|-----------------|-------------|----------------|
| **adb**         | Herramienta de depuración para Android | [ADB](https://developer.android.com/studio/command-line/adb) |
| **scrcpy**      | Control y mirror de dispositivos Android vía USB/TCP | [Scrcpy](https://github.com/Genymobile/scrcpy) |

---

### OSINT & Forense
| Herramienta     | Descripción | Enlace Oficial |
|-----------------|-------------|----------------|
| **sherlock**    | Búsqueda de usuarios en redes sociales | [Sherlock](https://github.com/sherlock-project/sherlock) |
| **binwalk**     | Análisis y extracción de firmware | [Binwalk](https://github.com/ReFirmLabs/binwalk) |

## Exploits y Vulnerabilidades
| Herramienta     | Descripción | Enlace Oficial |
|-----------------|-------------|----------------|
| exploit-db      | Base de datos de exploits y vulnerabilidades | [Exploit-DB](https://www.exploit-db.com/) |

# HTB Machine Enumerator

Herramienta CLI desarrollada en Bash para enumerar y consultar máquinas de Hack The Box utilizando un dataset público.

## Características

- Descarga incremental del dataset
- Validación automática de dependencias
- Ejecución segura (`set -euo pipefail`)
- Búsqueda por nombre
- Búsqueda por dirección IP
- Estructura modular preparada para escalabilidad

## Instalación

```bash
git clone https://github.com/hlmm7/htb-machine-enumerator.git
cd htb-machine-enumerator
chmod +x src/htb.sh

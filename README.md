# xtoxico's Arch Linux Config

Este repositorio contiene mi configuración personal de Arch Linux, incluyendo listas de paquetes, configuraciones de shell (Zsh, Nano) y personalización de GNOME.

## Contenido
- `setup.sh`: Script de automatización para restaurar todo el entorno.
- `pkglist.txt`: Lista de paquetes instalados vía `pacman`.
- `aurlist.txt`: Lista de paquetes instalados vía `AUR`.
- `configs/`: Archivos de configuración (`.zshrc`, `.nanorc`, dconf de GNOME).

## Cómo usar
1. Clona el repositorio:
   ```bash
   git clone https://github.com/xtoxico/xtoxicos-arch-config.git
   cd xtoxicos-arch-config
   ```
2. Da permisos de ejecución al script:
   ```bash
   chmod +x setup.sh
   ```
3. Ejecuta el script:
   ```bash
   ./setup.sh
   ```

## Requisitos
- Una instalación limpia de Arch Linux.
- Conexión a internet.

# xtoxico's Arch Linux Config

Este repositorio contiene mi configuración personal de Arch Linux, incluyendo listas de paquetes, configuraciones de shell (Zsh, Nano) y personalización de GNOME.

## Contenido
- `setup.sh`: Script de automatización para restaurar todo el entorno.
- `pkglist.txt`: Lista de paquetes instalados vía `pacman`.
- `aurlist.txt`: Lista de paquetes instalados vía `AUR`.
- `configs/`:
    - `zshrc` / `nanorc`: Configuraciones de shell y editor.
    - `gitconfig`: Configuración global de Git.
    - `btop/`: Configuración del monitor de sistema btop.
    - `*.dconf`: Exportaciones de configuración de GNOME (Extensiones e Interfaz).

## Extensiones de GNOME incluidas
El script restaurará la configuración de las siguientes extensiones (si están instaladas):
- Bluetooth Battery Meter
- Vitals
- Tiling Assistant
- App Grid Tuner
- Caffeine
- User Themes
- Blur my Shell
- Dash to Dock
- Just Perfection

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

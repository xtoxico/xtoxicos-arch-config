# Arch Linux Config Manager (Multi-Profile & AI-Assisted)

Este repositorio ha evolucionado a un gestor avanzado de configuraciones para múltiples equipos, con cifrado de seguridad y asistencia por IA.

## Características
- **Multi-Perfil:** Soporta perfiles separados (ej. `desktop`, `thinkpad`).
- **Cifrado:** Los datos se guardan en `.github_vault.zip` con contraseña, protegiendo tu privacidad en GitHub.
- **Mix & Match:** El script `restore_partial.sh` permite mezclar configuraciones (ej. usar el Zsh del Sobremesa en el Portátil).
- **IA Gemini:** Genera bitácoras automáticas que explican qué hace cada configuración antes de restaurarla.
- **Respaldo de Sistema:** Soporte para `/etc/fstab`, `/etc/pam.d/`, y más.

## Instalación y Uso

1. **Clonar y Descifrar:**
   ```bash
   git clone https://github.com/xtoxico/xtoxicos-arch-config.git
   cd xtoxicos-arch-config
   ./setup.sh  # Selecciona la opción 6 para descifrar si ya tienes un vault.
   ```

2. **Realizar Backup:**
   Ejecuta `./setup.sh` y elige la opción 1. Al final podrás subirlo automáticamente a GitHub cifrado.

3. **Bitácora con IA:**
   Elige la opción 2. Necesitarás una Gemini API Key (se guardará en un archivo `.env` local).

4. **Restaurar:**
   - **Completo (Opción 3):** Aplica todo un perfil.
   - **Parcial (Opción 4):** Menú interactivo para elegir qué piezas restaurar de qué perfil.

## Seguridad
- La carpeta `profiles/` está en el `.gitignore`.
- **NUNCA** subas archivos en texto plano. Usa siempre el script de cifrado.
- Los archivos de sistema (`/etc`) se respaldan localmente con extensión `.bak` antes de ser sobrescritos.

## Estructura
- `scripts/`: Motores de backup y restauración.
- `profiles/`: (Local) Almacena los perfiles en texto plano.
- `.github_vault.zip`: (Remoto) Contenedor cifrado de tus perfiles.

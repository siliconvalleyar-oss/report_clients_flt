# Guía de Instalación - Electromedicina Pro

## Prerrequisitos

- Sistema operativo: Windows 10+, macOS 10.14+, o Linux
- Flutter SDK >= 3.0.0
- Dart SDK (viene incluido con Flutter)
- Android Studio >= 2022.1 o VS Code >= 1.70
- JDK >= 11
- Android SDK (API 21 - Android 5.0 o superior)
- Git

## Instalación de Flutter SDK

### Windows

```bash
# Descargar Flutter SDK desde https://docs.flutter.dev/get-started/install/windows
# Descomprimir en C:\src\flutter
# Agregar al PATH del sistema:
C:\src\flutter\bin
# Verificar instalación
flutter doctor
```

### macOS

```bash
# Usando Homebrew
brew install --cask flutter

# O descarga manual desde https://docs.flutter.dev/get-started/install/macos
# Agregar al ~/.zshrc o ~/.bashrc:
export PATH="$PATH:`pwd`/flutter/bin"

# Verificar instalación
flutter doctor
```

### Linux

```bash
# Descargar Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz
# Agregar al ~/.bashrc:
export PATH="$PATH:$HOME/flutter/bin"
source ~/.bashrc
flutter doctor
```

## Configuración de Android Studio / VS Code

### Android Studio

1. Instalar Android Studio desde https://developer.android.com/studio
2. Abrir Android Studio e ir a **Settings > Plugins**
3. Instalar los plugins **Flutter** y **Dart**
4. Configurar Android SDK en **Settings > Appearance & Behavior > System Settings > Android SDK**
5. Aceptar licencias: `flutter doctor --android-licenses`

### VS Code

1. Instalar VS Code desde https://code.visualstudio.com
2. Abrir VS Code e ir a **Extensiones** (Ctrl+Shift+X)
3. Instalar la extensión **Flutter** (y **Dart** como dependencia)
4. Abrir la paleta de comandos (Ctrl+Shift+P) y seleccionar **Flutter: New Project** para verificar

## Clonar Repositorio

```bash
git clone <url-del-repositorio>
cd report_clients_flt
```

## Obtener Dependencias

```bash
flutter pub get
```

## Ejecutar en Modo Desarrollo

Conecta un dispositivo físico o inicia un emulador:

```bash
flutter run
```

Para ejecutar en un dispositivo específico:

```bash
flutter devices
flutter run -d <device-id>
```

## Construir APK de Producción

```bash
flutter build apk --release
```

El APK se genera en `build/app/outputs/flutter-apk/app-release.apk`.

## Construir AppBundle

```bash
flutter build appbundle
```

El AppBundle se genera en `build/app/outputs/bundle/release/app-release.aab`.

## Solución de Errores Comunes

| Error | Solución |
|-------|----------|
| `flutter: command not found` | Verifica que Flutter esté en el PATH |
| `Android license not accepted` | Ejecuta `flutter doctor --android-licenses` |
| `Gradle build failed` | Ejecuta `flutter clean && flutter pub get` |
| `No devices found` | Conecta un dispositivo o inicia un emulador |
| `Dart SDK not found` | Reinstala Flutter SDK o verifica la instalación |
| `Plugin not installed` | Verifica que los plugins Flutter/Dart estén instalados en el IDE |

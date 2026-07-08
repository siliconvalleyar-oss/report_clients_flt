# Guía de Despliegue - Electromedicina Pro

## Preparación para Producción

Antes de generar una build de producción, verifica lo siguiente:

1. **Versión de la app**: Actualiza `version` en `pubspec.yaml`
2. **Número de build**: Incrementa `buildNumber` en `pubspec.yaml`
3. **Configuración de producción**: Revisa que las URLs y credenciales apunten a producción
4. **Iconos y splash screen**: Deben estar en alta resolución

## Configuración de Iconos y Splash Screen

### Iconos de la App

Usa `flutter_launcher_icons` para generar todos los tamaños de icono:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.0

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

### Splash Screen

Usa `flutter_native_splash` para configurar la pantalla de carga:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_native_splash: ^2.3.0

flutter_native_splash:
  color: "#FFFFFF"
  image: "assets/splash/splash_logo.png"
  android: true
  ios: true
```

```bash
flutter pub get
flutter pub run flutter_native_splash:create
```

## Firma de APK

### 1. Generar Keystore

```bash
keytool -genkey -v -keystore release.keystore -alias release \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass <contraseña> -keypass <contraseña>
```

Mueve el archivo `release.keystore` a `android/app/`.

### 2. Crear `key.properties`

Crea el archivo `android/key.properties`:

```properties
storePassword=<contraseña>
keyPassword=<contraseña>
keyAlias=release
storeFile=release.keystore
```

### 3. Configurar Gradle

En `android/app/build.gradle`, asegúrate de que la configuración de firma esté presente:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ...
        }
    }
}
```

## Build Release

```bash
# Limpiar compilación anterior
flutter clean

# Obtener dependencias
flutter pub get

# Generar APK firmado
flutter build apk --release

# Generar AppBundle firmado (para Play Store)
flutter build appbundle --release
```

Los archivos generados estarán en:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## Publicación en Google Play Store

### Requisitos

1. Cuenta de desarrollador en Google Play Console ($25 USD, pago único)
2. AppBundle firmado (`.aab`)
3. Icono de la app (512x512 px, 32-bit PNG)
4. Gráficos destacados (1024x500 px)
5. Screenshots (al menos 2 por dispositivo, mínimo 320 px)
6. Descripción corta (máximo 80 caracteres)
7. Descripción completa (máximo 4000 caracteres)
8. Categoría: "Medical"
9. Política de privacidad (URL)

### Checklist Pre-Publicación

- [ ] La app no tiene errores críticos
- [ ] Todos los campos de texto no contienen texto de prueba
- [ ] Los iconos y splash screen están configurados
- [ ] La firma digital está configurada correctamente
- [ ] El número de versión es correcto
- [ ] Las cadenas de texto están internacionalizadas
- [ ] La política de privacidad está disponible
- [ ] Las API keys de Google Drive están configuradas
- [ ] Se probó en múltiples dispositivos/versiones de Android
- [ ] La app cumple con las políticas de Google Play

### Screenshots Recomendados

| Dispositivo | Resolución | Cantidad |
|-------------|------------|----------|
| Teléfono | 1080x1920 px | 4-8 |
| Tablet | 2000x1200 px | 2-4 |

### Pasos en Google Play Console

1. Ir a Google Play Console y crear una nueva aplicación
2. Completar la ficha de la tienda (Store Listing)
3. Subir el AppBundle en la sección "Production"
4. Completar la información de contenido (Content Rating, Pricing & Distribution)
5. Revisar y publicar

## Publicación en Otras Plataformas

### App Store (iOS)

1. Mac con Xcode 14+
2. Cuenta de desarrollador Apple ($99/año)
3. Configurar certificados y perfiles de aprovisionamiento
4. Ejecutar `flutter build ios --release`
5. Abrir el proyecto en Xcode y subir a App Store Connect

### Huawei AppGallery

1. Cuenta de desarrollador Huawei
2. Configurar HMS (Huawei Mobile Services)
3. Generar APK firmado
4. Subir a AppGallery Connect

## Actualizaciones y Versionado

### Versionado Semántico

```
v1.0.0 - Lanzamiento inicial
v1.1.0 - Nuevas características compatibles con versiones anteriores
v1.1.1 - Correcciones de bugs compatibles con versiones anteriores
v2.0.0 - Cambios incompatibles con versiones anteriores
```

### Proceso de Actualización

1. Incrementar la versión en `pubspec.yaml`
2. Actualizar `CHANGELOG.md`
3. Ejecutar pruebas
4. Generar build de producción
5. Subir a Google Play Console (o plataforma correspondiente)
6. Publicar la actualización

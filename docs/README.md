# Electromedicina Pro - Reportes Técnicos

Aplicación móvil Flutter para la generación y gestión de reportes técnicos de electromedicina. Permite crear, almacenar y exportar reportes profesionales en formato PDF, compartirlos vía WhatsApp, Email y Google Drive, y mantener un historial completo con búsqueda integrada.

## Requisitos del Sistema

- Flutter SDK >= 3.0.0
- Dart (incluido con Flutter)
- Android Studio (con plugins Flutter y Dart) o VS Code
- JDK 11 o superior
- Android SDK (API 21+)

## Guía Rápida de Instalación

```bash
# Clonar el repositorio
git clone <repo-url>
cd report_clients_flt

# Obtener dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run

# Construir APK de producción
flutter build apk --release
```

## Configuración del Entorno

1. Asegúrate de tener Flutter instalado: `flutter doctor`
2. Configura las variables de entorno necesarias en el archivo `.env` (si aplica)
3. Para Google Drive API, configura el archivo `google-services.json` en `android/app/`

## Estructura del Proyecto

```
report_clients_flt/
├── lib/
│   ├── controllers/       # Controladores (Report, Export, Validation)
│   ├── models/            # Modelos de datos
│   ├── services/          # Servicios (PDF, Storage, Export)
│   ├── views/             # Pantallas y widgets
│   ├── utils/             # Constantes, helpers, temas
│   └── main.dart          # Punto de entrada
├── assets/                # Recursos gráficos, fuentes, iconos
├── test/                  # Tests unitarios
├── android/               # Configuración Android
├── ios/                   # Configuración iOS
├── docs/                  # Documentación
└── pubspec.yaml           # Dependencias
```

## Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `flutter pub get` | Obtiene las dependencias |
| `flutter run` | Ejecuta en modo debug |
| `flutter build apk --release` | Genera APK de producción |
| `flutter build appbundle` | Genera AppBundle para Play Store |
| `flutter test` | Ejecuta pruebas |
| `flutter clean` | Limpia la caché de compilación |
| `flutter format .` | Formatea el código |
| `flutter analyze` | Analiza el código en busca de errores |

## Solución de Problemas Comunes

- **`flutter doctor` muestra errores**: Verifica que Android SDK, JDK y los plugins estén correctamente instalados.
- **Error de Gradle**: Ejecuta `flutter clean` y luego `flutter pub get`.
- **Problemas con Hive**: Borra los archivos de caché de la app en el dispositivo.
- **Error de firma**: Verifica el archivo `key.properties` y la ruta del keystore.

# Arquitectura del Sistema

## MVC Architecture (Model-View-Controller)

La aplicación sigue el patrón MVC (Model-View-Controller) organizado en capas bien definidas:

```
┌─────────────────────────────────────────────────────┐
│                    VIEWS (UI)                        │
│  Screens / Widgets / Pages                          │
│  - HomeScreen, ReportFormScreen,                    │
│    HistoryScreen, SettingsScreen                    │
└──────────────────────┬──────────────────────────────┘
                       │ Provider (notifica cambios)
                       ▼
┌─────────────────────────────────────────────────────┐
│                CONTROLLERS                           │
│  Lógica de negocio y estado                         │
│  - ReportController                                 │
│  - ExportController                                 │
│  - ValidationController                             │
└──────────────────────┬──────────────────────────────┘
                       │ Llamadas a servicios
                       ▼
┌─────────────────────────────────────────────────────┐
│                   SERVICES                           │
│  Lógica de aplicación y acceso a datos              │
│  - PdfService                                        │
│  - StorageService (Hive)                             │
│  - ExportService                                     │
└──────────────────────┬──────────────────────────────┘
                       │ Lectura/escritura
                       ▼
┌─────────────────────────────────────────────────────┐
│                    MODELS                            │
│  Estructuras de datos                               │
│  - ReportModel                                       │
│  - ClientModel                                       │
│  - EquipmentModel                                    │
│  - ServiceModel                                      │
└─────────────────────────────────────────────────────┘
```

## Diagrama de Flujo de Datos

```
Usuario                  View                Controller            Service               Model
  │                       │                     │                     │                     │
  │── Ingresa datos ─────►│                     │                     │                     │
  │                       │── validate() ──────►│                     │                     │
  │                       │                     │── validateData() ──►│                     │
  │                       │                     │◄─ result ──────────│                     │
  │                       │◄─ errors ──────────│                     │                     │
  │── Corrige datos ─────►│                     │                     │                     │
  │                       │── save() ──────────►│                     │                     │
  │                       │                     │── saveReport() ────►│                     │
  │                       │                     │                     │── toMap() ──────────►│
  │                       │                     │                     │◄─ Map ──────────────│
  │                       │                     │                     │── Hive.put() ───────►│
  │                       │                     │◄─ success ─────────│                     │
  │                       │◄─ success ──────────│                     │                     │
  │◄─ Confirmación ──────│                     │                     │                     │
  │                       │                     │                     │                     │
  │── Exporta ───────────►│                     │                     │                     │
  │                       │── exportPdf() ─────►│                     │                     │
  │                       │                     │── generatePdf() ───►│                     │
  │                       │                     │◄─ File ────────────│                     │
  │                       │                     │── share() ─────────►│                     │
  │◄─ Compartido ────────│                     │                     │                     │
```

## Descripción de Cada Capa

### Models
Representan las estructuras de datos de la aplicación. Cada modelo incluye métodos `toMap()` y `fromMap()` para serialización/deserialización con Hive. Utilizan anotaciones `@HiveType` y `@HiveField` para el almacenamiento.

### Views
Contiene todas las pantallas y widgets de la interfaz de usuario. Implementadas con Flutter Widgets. Cada view se comunica con su controller a través de Provider, escuchando cambios de estado y enviando acciones del usuario.

### Controllers
Manejan la lógica de negocio y el estado de la aplicación. Utilizan `ChangeNotifier` de Provider para notificar a las vistas sobre cambios en el estado. Validan datos antes de pasarlos a los servicios.

### Services
Capa de servicios que contiene la lógica de aplicación:
- **PdfService**: Generación de PDF usando la librería `pdf` (Dart PDF)
- **StorageService**: Almacenamiento persistente con Hive
- **ExportService**: Manejo de exportación a diferentes plataformas usando `share_plus`, `url_launcher`, `googleapis`

## Gestión de Estado con Provider

La aplicación usa `provider` como solución de gestión de estado:

```dart
// Configuración en main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ReportController()),
    ChangeNotifierProvider(create: (_) => ExportController()),
    ChangeNotifierProvider(create: (_) => ValidationController()),
    ChangeNotifierProvider(create: (_) => ThemeController()),
  ],
  child: const App(),
)

// Consumo en vistas
final reportController = context.watch<ReportController>();
final reports = reportController.reports;

// Acción desde vista
context.read<ReportController>().createReport();
```

## Almacenamiento Local con Hive

Hive es una base de datos NoSQL rápida y ligera:

```dart
// Inicialización
await Hive.initFlutter();
Hive.registerAdapter(ReportModelAdapter());
Hive.registerAdapter(ClientModelAdapter());
// ...

// Operaciones
final box = await Hive.openBox<ReportModel>('reports');
await box.put(report.id, report);
final report = box.get(id);
final allReports = box.values.toList();
```

### Tipos Adaptados

| Tipo | Adapter |
|------|---------|
| `ReportModel` | `ReportModelAdapter` |
| `ClientModel` | `ClientModelAdapter` |
| `EquipmentModel` | `EquipmentModelAdapter` |
| `ServiceModel` | `ServiceModelAdapter` |
| `AppConfig` | `AppConfigAdapter` |

## Servicios de Exportación

### Exportación a PDF
1. `PdfService.generateReport()` genera el documento PDF usando la librería `pdf`
2. El PDF se escribe en un archivo temporal usando `path_provider`
3. El archivo se retorna al controller para su posterior uso

### Exportación a WhatsApp
1. Se obtiene el archivo PDF generado
2. Se usa `share_plus` para compartir el archivo
3. El sistema muestra el selector de apps para compartir (WhatsApp, etc.)

### Exportación a Email
1. Se genera el PDF
2. Se crea un URI del archivo
3. Se lanza el cliente de email con `url_launcher` usando el esquema `mailto:`

### Exportación a Google Drive
1. Se autentica al usuario con OAuth 2.0
2. Se usa la API de Google Drive (`googleapis`) para subir el archivo
3. Se muestra confirmación de subida exitosa

## Flujo de Creación de Reportes

```
1. Usuario presiona "+" (nuevo reporte)
       │
2. ReportController.createReport()
       │
3. Se navega al formulario paso a paso (Stepper)
       │
4. Paso 1: Datos del cliente → ValidationController.validateClientData()
       │
5. Paso 2: Datos del equipo → ValidationController.validateEquipmentData()
       │
6. Paso 3: Datos del servicio → ValidationController.validateServiceData()
       │
7. Paso 4: Firma digital → ValidationController.validateSignature()
       │
8. Resumen → Usuario confirma los datos
       │
9. ReportController.saveReport()
       │
10. StorageService.saveReport() → Hive guarda los datos
       │
11. Navegación de vuelta a la pantalla de inicio
       │
12. (Opcional) ExportController.exportToPdf() + share
```

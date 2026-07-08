# Documentación de API Interna

## ReportController

Controlador principal para la gestión de reportes técnicos.

### Métodos

| Método | Descripción | Parámetros | Retorno |
|--------|-------------|------------|---------|
| `createReport()` | Crea un nuevo reporte vacío | - | `ReportModel` |
| `saveReport(ReportModel)` | Guarda un reporte en almacenamiento local | `report`: ReportModel | `Future<void>` |
| `getReport(String id)` | Obtiene un reporte por su ID | `id`: String | `Future<ReportModel?>` |
| `getAllReports()` | Obtiene todos los reportes guardados | - | `Future<List<ReportModel>>` |
| `searchReports(String query)` | Busca reportes por texto | `query`: String | `Future<List<ReportModel>>` |
| `deleteReport(String id)` | Elimina un reporte | `id`: String | `Future<void>` |
| `updateReport(ReportModel)` | Actualiza un reporte existente | `report`: ReportModel | `Future<void>` |

### Propiedades

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `currentReport` | `ReportModel?` | Reporte actual en edición |
| `reports` | `List<ReportModel>` | Lista de todos los reportes |
| `isLoading` | `bool` | Estado de carga |

---

## ExportController

Controlador para la exportación de reportes a diferentes plataformas.

### Métodos

| Método | Descripción | Parámetros |
|--------|-------------|------------|
| `exportToPdf(ReportModel)` | Genera y guarda el PDF del reporte | `report`: ReportModel |
| `shareViaWhatsApp(ReportModel)` | Comparte el PDF vía WhatsApp | `report`: ReportModel |
| `shareViaEmail(ReportModel)` | Comparte el PDF vía Email | `report`: ReportModel |
| `shareViaDrive(ReportModel)` | Sube el PDF a Google Drive | `report`: ReportModel |
| `shareFile(File file)` | Comparte un archivo usando el share sheet del sistema | `file`: File |

---

## ValidationController

Controlador de validación de campos del formulario.

### Métodos

| Método | Descripción | Parámetros | Retorno |
|--------|-------------|------------|---------|
| `validateClientData(ClientModel)` | Valida datos del cliente | `client`: ClientModel | `bool` |
| `validateEquipmentData(EquipmentModel)` | Valida datos del equipo | `equipment`: EquipmentModel | `bool` |
| `validateServiceData(ServiceModel)` | Valida datos del servicio | `service`: ServiceModel | `bool` |
| `validateSignature(Uint8List?)` | Valida que la firma esté presente | `signature`: Uint8List? | `bool` |
| `validateAll(ReportModel)` | Valida todos los campos del reporte | `report`: ReportModel | `Map<String, bool>` |

### Mensajes de Error

| Campo | Validación | Mensaje |
|-------|------------|---------|
| `clientName` | No vacío | "El nombre del cliente es obligatorio" |
| `equipmentType` | No vacío | "El tipo de equipo es obligatorio" |
| `serviceDescription` | No vacío, mínimo 10 caracteres | "La descripción debe tener al menos 10 caracteres" |
| `signature` | No nula | "La firma del cliente es obligatoria" |

---

## PdfService

Servicio de generación de documentos PDF.

### Métodos

| Método | Descripción | Parámetros | Retorno |
|--------|-------------|------------|---------|
| `generateReport(ReportModel)` | Genera el PDF completo del reporte | `report`: ReportModel | `Future<File>` |
| `generatePreview(ReportModel)` | Genera una vista previa del PDF | `report`: ReportModel | `Future<Uint8List>` |

### Formato del PDF

- Tamaño: A4
- Orientación: Vertical (Portrait)
- Encabezado: Logo de la empresa, título "Reporte Técnico", número de reporte
- Cuerpo:
  - Datos del cliente (nombre, RUT, dirección, teléfono, email)
  - Datos del equipo (tipo, marca, modelo, número de serie, ubicación)
  - Datos del servicio (tipo, fecha, descripción, observaciones)
  - Firma digital del cliente
- Pie de página: Fecha de emisión, página X de Y

---

## StorageService

Servicio de almacenamiento local usando Hive.

### Métodos

| Método | Descripción | Parámetros |
|--------|-------------|------------|
| `init()` | Inicializa Hive y abre las cajas | - |
| `saveReport(ReportModel)` | Guarda un reporte en Hive | `report`: ReportModel |
| `getReport(String id)` | Obtiene un reporte por ID | `id`: String |
| `getAllReports()` | Obtiene todos los reportes | - |
| `searchReports(String query)` | Busca reportes por texto | `query`: String |
| `deleteReport(String id)` | Elimina un reporte | `id`: String |
| `clearAll()` | Elimina todos los reportes | - |

### Estructura de Datos en Hive

| Box | Tipo | Descripción |
|-----|------|-------------|
| `reports` | `ReportModel` | Almacena todos los reportes |
| `config` | `AppConfig` | Configuración de la app (tema, idioma) |

---

## Modelos

### ReportModel

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `String` | Identificador único (UUID) |
| `reportNumber` | `String` | Número de reporte (formato: R-YYYY-NNNN) |
| `createdAt` | `DateTime` | Fecha de creación |
| `updatedAt` | `DateTime` | Fecha de última modificación |
| `client` | `ClientModel` | Datos del cliente |
| `equipment` | `EquipmentModel` | Datos del equipo |
| `service` | `ServiceModel` | Datos del servicio |
| `signature` | `Uint8List?` | Firma digital del cliente |
| `status` | `ReportStatus` | Estado del reporte (draft, completed, exported) |

### ClientModel

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `name` | `String` | Nombre del cliente |
| `rut` | `String` | RUT del cliente |
| `address` | `String` | Dirección |
| `phone` | `String` | Teléfono de contacto |
| `email` | `String` | Correo electrónico |

### EquipmentModel

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `type` | `String` | Tipo de equipo |
| `brand` | `String` | Marca |
| `model` | `String` | Modelo |
| `serialNumber` | `String` | Número de serie |
| `location` | `String` | Ubicación del equipo |

### ServiceModel

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `type` | `ServiceType` | Tipo de servicio (preventivo, correctivo, instalación) |
| `date` | `DateTime` | Fecha del servicio |
| `description` | `String` | Descripción del trabajo realizado |
| `observations` | `String` | Observaciones adicionales |
| `technicianName` | `String` | Nombre del técnico |
| `technicianSignature` | `Uint8List?` | Firma del técnico |

---

## Constantes y Utilidades

### AppConstants (`lib/utils/constants.dart`)

| Constante | Valor | Descripción |
|-----------|-------|-------------|
| `appName` | "Electromedicina Pro" | Nombre de la aplicación |
| `appVersion` | "1.0.0" | Versión actual |
| `pdfTitle` | "Reporte Técnico" | Título del PDF |
| `dateFormat` | "dd/MM/yyyy" | Formato de fecha |
| `reportPrefix` | "R-" | Prefijo del número de reporte |

### AppTheme (`lib/utils/theme.dart`)

| Propiedad | Descripción |
|-----------|-------------|
| `lightTheme` | Tema claro (modo por defecto) |
| `darkTheme` | Tema oscuro |

### Helpers (`lib/utils/helpers.dart`)

| Función | Descripción |
|---------|-------------|
| `formatDate(DateTime)` | Formatea una fecha según el formato definido |
| `generateReportNumber()` | Genera el número de reporte secuencial |
| `generateUUID()` | Genera un identificador único |
| `validateEmail(String)` | Valida formato de email |
| `validateRut(String)` | Valida formato de RUT chileno |
| `formatCurrency(double)` | Formatea un valor monetario |

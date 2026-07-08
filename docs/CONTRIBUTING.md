# Guía para Contribuir - Electromedicina Pro

Gracias por tu interés en contribuir al proyecto. Por favor, sigue estas pautas para mantener la calidad y consistencia del código.

## Cómo Reportar Bugs

1. **Verifica que el bug no haya sido reportado** buscando en los issues existentes
2. **Crea un nuevo issue** usando la plantilla de bug report
3. **Incluye la siguiente información**:
   - Versión de la app y del dispositivo
   - Pasos para reproducir el bug
   - Comportamiento esperado vs comportamiento actual
   - Capturas de pantalla o video si es posible
   - Logs de error relevantes

## Cómo Solicitar Features

1. **Revisa los issues existentes** para ver si la feature ya fue solicitada
2. **Crea un nuevo issue** usando la plantilla de feature request
3. **Describe claramente**:
   - El problema que resuelve la feature
   - Cómo debería funcionar
   - Alternativas consideradas
   - Capturas de mockups si aplica

## Estándares de Código

- **Estilo**: Sigue las reglas de `flutter_lint` y el estilo oficial de Dart
- **Formateo**: El código debe estar formateado con `dart format`
- **Nombres**: Usa `camelCase` para variables y métodos, `PascalCase` para clases
- **Longitud de línea**: Máximo 100 caracteres
- **Archivos**: Un widget/clase por archivo, nombrado según la clase
- **Imports**: Ordena los imports: dart, flutter, paquetes externos, locales

## Conventional Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/) para los mensajes de commit:

```
<type>(<scope>): <descripción>

[opcional: cuerpo del mensaje]

[opcional: pie con breaking changes o referencias a issues]
```

### Tipos de Commit

| Tipo | Descripción |
|------|-------------|
| `feat` | Nueva característica |
| `fix` | Corrección de bug |
| `docs` | Cambios en documentación |
| `style` | Cambios de formato (no afectan lógica) |
| `refactor` | Refactorización de código (no cambia funcionalidad) |
| `test` | Adición o modificación de tests |
| `chore` | Cambios en build, dependencias, etc. |
| `perf` | Mejora de rendimiento |

### Ejemplos

```
feat(report): add client signature capture
fix(export): resolve PDF generation crash on Android 12
docs(readme): update installation instructions
refactor(controller): extract validation logic
```

## Proceso de Pull Request

1. **Crea un fork** del repositorio
2. **Crea una rama** desde `main` con el formato:
   - `feat/nombre-de-la-feature`
   - `fix/nombre-del-fix`
   - `docs/nombre-del-cambio`
3. **Realiza tus cambios** siguiendo los estándares de código
4. **Ejecuta las pruebas**:
   ```bash
   flutter test
   flutter analyze
   ```
5. **Actualiza la documentación** si es necesario
6. **Actualiza el CHANGELOG** si aplica
7. **Crea el Pull Request** con:
   - Título descriptivo siguiendo Conventional Commits
   - Descripción clara de los cambios
   - Referencia a issues relacionados
   - Screenshots si hay cambios visuales

### Review del PR

- Un mantenedor revisará tu PR
- Se pueden solicitar cambios o aclaraciones
- Una vez aprobado, se hará merge a `main`

## Entorno de Desarrollo

### Configuración Inicial

```bash
git clone <tu-fork-url>
cd report_clients_flt
git remote add upstream <repo-original-url>
git checkout -b feat/mi-feature
flutter pub get
flutter run
```

### Mantener el Fork Actualizado

```bash
git fetch upstream
git rebase upstream/main
```

## Ejecución de Pruebas

```bash
# Ejecutar todas las pruebas
flutter test

# Ejecutar pruebas con cobertura
flutter test --coverage

# Ejecutar un archivo de prueba específico
flutter test test/controllers/report_controller_test.dart

# Analizar el código
flutter analyze
```

### Cobertura Mínima

- Controllers: 80%
- Services: 70%
- Models: 90%
- Utils: 70%

### Estructura de Tests

```
test/
├── controllers/
│   └── report_controller_test.dart
├── services/
│   ├── pdf_service_test.dart
│   └── storage_service_test.dart
├── models/
│   ├── report_model_test.dart
│   ├── client_model_test.dart
│   └── equipment_model_test.dart
└── utils/
    └── helpers_test.dart
```

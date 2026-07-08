# report_clients_flt

Aplicación Flutter para generación de reportes técnicos de electromedicina.

> **⚠️ IMPORTANTE: Antes de modificar cualquier archivo, leer [`docs/RULES.md`](docs/RULES.md) — contiene las reglas de oro del proyecto que toda AI y desarrollador debe respetar obligatoriamente.**

## Características

- Formulario PDF profesional tipo impreso de una hoja A4
- Datos de empresa, logo y sello configurables
- Marcas/modelos personalizados, empleados, cargos, agenda de clientes
- Presupuesto, costos e items dinámicos
- Fondo de reporte configurable (imagen + opacidad ajustable)
- Splash animado con versión
- Modo oscuro azul
- Exportación e impresión de PDF

## Requisitos

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0

## Instalación rápida

```bash
git clone <repo-url>
cd report_clients_flt
flutter pub get
flutter run
```

## Documentación

| Archivo | Descripción |
|---------|-------------|
| [`docs/RULES.md`](docs/RULES.md) | **Reglas de oro del proyecto (obligatorio leer)** |
| [`docs/README.md`](docs/README.md) | Documentación completa del proyecto |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Arquitectura del sistema |
| [`docs/INSTALL.md`](docs/INSTALL.md) | Guía de instalación detallada |
| [`docs/DEPLOY.md`](docs/DEPLOY.md) | Despliegue y compilación |
| [`docs/CHANGELOG.md`](docs/CHANGELOG.md) | Historial de versiones |
| [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) | Guía para contribuir |

## Estructura del proyecto

```
lib/
  controllers/    # Lógica de negocio
  models/         # Modelos de datos
  views/          # Pantallas e interfaces
  services/       # Servicios (PDF, storage, export)
  utils/          # Constantes, temas, helpers
  main.dart       # Punto de entrada
assets/
  logo/           # Logos corporativos
  marca/          # Marca de agua
  svg/            # SVG animado (presentación)
  fondo/          # Imágenes de fondo para PDF
docs/             # Documentación
  RULES.md        # ⚠️ Reglas de oro (inmutable)
```

## Licencia

MIT License - Copyright (c) 2026 siliconvalleyar-oss

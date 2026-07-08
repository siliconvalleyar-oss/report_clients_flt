# report_clients_flt

Aplicación Flutter para generación de reportes técnicos de electromedicina.

## Características

- Gestión de clientes y equipos médicos
- Generación de reportes técnicos en PDF
- Firmas digitales integradas
- Almacenamiento local con Hive
- Vista previa e impresión de reportes
- Compartir reportes por correo y otras apps
- Interfaz intuitiva basada en Material Design

## Requisitos

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0
- Soporte para Android / iOS / Web / Linux

## Instalación rápida

```bash
git clone <repo-url>
cd report_clients_flt
flutter pub get
flutter run
```

## Estructura del proyecto

```
lib/
  controllers/    # Lógica de negocio (Controladores)
  models/         # Modelos de datos
  views/          # Pantallas e interfaces de usuario
  services/       # Servicios (PDF, impresión, etc.)
  widgets/        # Widgets reutilizables
  app.dart        # Configuración principal de la app
  main.dart       # Punto de entrada
assets/
  logo.png
  watermark.png
  fonts/
```

## Licencia

MIT License - Copyright (c) 2026 siliconvalleyar-oss

name: report-clients-flt
description: Desarrollo y mantenimiento de la app Flutter para reportes técnicos de electromedicina

## Contexto del Proyecto

App Flutter para generar reportes técnicos de electromedicina en formato PDF A4 con:
- Formulario tipo con campos en posiciones fijas (estilo formulario impreso)
- Datos de empresa configurables (nombre, dirección, teléfono, email, logo, sello)
- Marcas/modelos personalizados, empleados, cargos, agenda de clientes
- Presupuesto, costos, items dinámicos (repuestos)
- Tipografía configurable (Helvetica, Times-Roman, Courier)
- Fondo de reporte configurable (imagen con opacidad ajustable 0-100%)
- Exportación e impresión de PDF

## Reglas de Oro (ver docs/RULES.md)

1. **Siempre reemplazar, nunca desinstalar**: `flutter build apk --release` + `adb install -r`
2. **Versionado**: cada push lleva su tag; VERSION = último tag; siguiente = tag + 0.0.1
3. **La app siempre muestra la versión** en splash screen y Acerca de
4. **PDF en una sola hoja A4**: todo apilado verticalmente al ancho completo
5. **FontWeight**: solo `normal`/`bold` (no w200/w300/w400)
6. **docs/RULES.md es inmutable** — solo el dueño del proyecto lo modifica

## Stack Técnico

- Flutter 3.x, Dart 3.x
- pdf: ^3.8.0, printing: ^5.9.0
- flutter_svg: ^2.0.0, hive_flutter: ^1.1.0
- provider, image_picker, share_plus

## Estructura Clave

- `lib/services/industrial_form_template.dart` — generación del PDF formulario
- `lib/services/pdf_service.dart` — wrapper que llama al template
- `lib/services/storage_service.dart` — persistencia Hive
- `lib/views/screens/settings_screen.dart` — configuración completa
- `lib/views/screens/splash_screen.dart` — splash animado 3s
- `docs/RULES.md` — reglas de oro del proyecto

## Comandos Frecuentes

```bash
# Build + instalar (reemplazar)
flutter build apk --release && adb install -r build/app/outputs/flutter-apk/app-release.apk

# Análisis
flutter analyze --no-fatal-infos --no-fatal-warnings
```

# Assets en Flutter - Red Carga

## Estructura de Carpetas

En Flutter, los assets se organizan diferente que en Android nativo:

```
assets/
├── images/     # Imágenes (PNG, JPG, etc.)
└── icons/      # Iconos vectoriales (SVG)
```

## Diferencias con Android Nativo

### Android Nativo
- Usa `res/drawable/` para recursos
- Los vector drawables son archivos `.xml`

### Flutter
- Usa `assets/` en la raíz del proyecto
- Los iconos vectoriales deben ser `.svg` (no `.xml`)
- Se declaran en `pubspec.yaml`

## Cómo Migrar Iconos XML a Flutter

Los archivos XML vector drawables de Android necesitan convertirse a SVG:

1. **Opción 1: Convertir manualmente**
   - Abre el XML en un editor
   - Copia el contenido del path
   - Crea un nuevo archivo SVG con la estructura SVG estándar

2. **Opción 2: Usar herramientas online**
   - Herramientas como `android-to-svg` o `vector-drawable-to-svg`
   - O usar Android Studio para exportar como SVG

3. **Opción 3: Usar el paquete `flutter_svg`**
   - Instala: `flutter pub add flutter_svg`
   - Algunos XML pueden funcionar directamente con conversión

## Uso en Código

```dart
// Para imágenes PNG/JPG
Image.asset('assets/images/mi_imagen.png')

// Para iconos SVG (requiere flutter_svg - YA INSTALADO)
import 'package:flutter_svg/flutter_svg.dart';

// Uso básico
SvgPicture.asset('assets/icons/mi_icono.svg')

// Con tamaño personalizado
SvgPicture.asset(
  'assets/icons/mi_icono.svg',
  width: 100,
  height: 100,
  color: RcColors.rcColor5, // Opcional: cambiar color
)
```

## ✅ Compatibilidad con Android Studio

**SÍ, Flutter acepta SVG sin problemas cuando se compila en Android Studio.**

El paquete `flutter_svg` está instalado y funciona perfectamente en:
- ✅ Android Studio
- ✅ VS Code
- ✅ Compilación para Android
- ✅ Compilación para iOS
- ✅ Compilación para Web

**Nota importante:** Flutter NO soporta SVG nativamente. Siempre necesitas el paquete `flutter_svg` (ya está agregado en este proyecto).

## Archivos XML del Proyecto Android

Los siguientes archivos XML del proyecto Android necesitan convertirse:
- `ic_agent_welcome_sign.xml`
- `ic_cargo_truck.xml`
- `ic_clipboard_edit.xml`
- `ic_gavel_resolution.xml`
- `ic_handshake_deal.xml`
- `ic_incident_alert.xml`
- `ic_mascot_alert.xml`
- `ic_payment_verified.xml`
- `ic_worker_carry_box.xml`
- `ic_worker_celebrate.xml`
- `ic_worker_happy.xml`
- `ic_worker_smile.xml`


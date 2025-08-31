# 🚌 TransApp - Splash Screen Implementation

## ✨ Características del Splash Screen

### 🎨 **Diseño Visual**
- **Gradiente dinámico** con los colores de la aplicación
- **Logo central animado** con efecto de pulso y sombras
- **Partículas flotantes** en el fondo
- **Iconos de transporte** con animaciones secuenciales
- **Tipografía elegante** con efectos de transición

### 🎭 **Animaciones Implementadas**

1. **Fade Animation** (1.5s)
   - Aparición suave de todos los elementos
   - Curva: `Curves.easeInOut`

2. **Scale Animation** (1.2s)
   - Logo crece desde 30% a 100%
   - Curva: `Curves.elasticOut` (efecto rebote)

3. **Slide Animation** (1s)
   - Texto desliza desde abajo
   - Curva: `Curves.easeOutCubic`

4. **Rotation Animation** (2s)
   - Rotación sutil del logo
   - Curva: `Curves.easeInOut`

5. **Transport Icons** (secuencial)
   - Cada ícono aparece con delay de 200ms
   - Efecto elástico individual

6. **Floating Particles**
   - 8 partículas que flotan hacia arriba
   - Diferentes tamaños y velocidades

### 📱 **Feedback Háptico**
- **Vibración inicial** al abrir la app
- **Vibración final** antes de la transición

### ⏱️ **Duración Total**
- **~3 segundos** de animación
- **Transición suave** a HomePage (600ms)

## 🚀 **Cómo Ejecutar**

### 1. Preparar el entorno
```bash
flutter doctor
flutter pub get
```

### 2. Ejecutar la aplicación
```bash
flutter run
```

### 3. Ejecutar en web
```bash
flutter run -d chrome
```

## 📁 **Archivos Modificados**

### `lib/main.dart`
```dart
// Cambiado de HomePage a SplashScreen
home: const SplashScreen(),
```

### `lib/pages/splash_screen.dart` (NUEVO)
- Splash screen completo con animaciones
- Navegación automática a HomePage
- Efectos visuales y sonoros

## 🎯 **Flujo de Navegación**

```
App Start → SplashScreen (3s) → HomePage → Login → Dashboard
```

## 🎨 **Paleta de Colores del Splash**

- **Azul Oscuro**: `#0B0530`
- **Púrpura Principal**: `#4F46E5`
- **Azul Medio**: `#197B9C`
- **Blanco**: Para texto y efectos

## 🔧 **Personalización**

### Cambiar duración del splash:
```dart
// En splash_screen.dart, línea ~88
await Future.delayed(const Duration(milliseconds: 2800));
```

### Modificar texto:
```dart
// Título principal
'TransApp'

// Subtítulo
'Tu transporte, tu ciudad'

// Texto de carga
'Preparando tu viaje...'
```

### Personalizar animaciones:
- Modificar `_initAnimations()` para ajustar curvas y duraciones
- Cambiar iconos de transporte en `_buildTransportIcon()`

## 🐛 **Resolución de Problemas**

### Si no aparecen animaciones:
- Verificar que `TickerProviderStateMixin` esté implementado
- Comprobar que los controllers estén inicializados

### Si hay errores de compilación:
```bash
flutter clean
flutter pub get
flutter run
```

## 📱 **Compatibilidad**
- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Desktop (Windows, macOS, Linux)

## 🎉 **Resultado Final**
Un splash screen profesional y atractivo que:
- ✅ Mejora la experiencia de usuario
- ✅ Mantiene la identidad visual de la app
- ✅ Proporciona una transición suave
- ✅ Es completamente personalizable

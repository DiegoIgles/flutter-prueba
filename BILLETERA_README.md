# Sistema de Billetera Digital - Cliente

Este documento describe las nuevas funcionalidades implementadas para el sistema de billetera digital del cliente.

## 📱 Nuevas Funcionalidades Implementadas

### 1. Dashboard Principal del Cliente
- **Archivo**: `lib/pages/cliente_dashboard_page.dart`
- **Descripción**: Página principal con navegación por pestañas que incluye:
  - Vista de inicio con resumen del saldo
  - Información de ubicación en tiempo real
  - Accesos rápidos a funcionalidades principales
  - Navegación mediante BottomNavigationBar

### 2. Sistema de Billetera Digital
- **Archivo**: `lib/pages/cliente_billetera_page.dart`
- **Funcionalidades**:
  - Visualización del saldo actual en tiempo real
  - Simulación de escaneo de código QR para recargas
  - Proceso de confirmación de recargas
  - Actualización automática del saldo
  - Información detallada de la billetera

#### Simulación QR
- Simula un proceso de escaneo de 2 segundos
- Genera montos aleatorios predefinidos (10, 20, 50, 100, 200 BOB)
- Muestra diálogo de confirmación antes de procesar
- Integra con el endpoint `/billeteras/cargar` del backend

### 3. Perfil del Cliente
- **Archivo**: `lib/pages/cliente_perfil_page.dart`
- **Características**:
  - Visualización de información personal del cliente
  - Opciones de configuración (preparadas para futuro desarrollo)
  - Funcionalidad de cierre de sesión seguro
  - Información de la aplicación

### 4. Historial de Movimientos
- **Archivo**: `lib/pages/cliente_movimientos_page.dart`
- **Preparado para**:
  - Visualización de historial de transacciones
  - Filtrado por tipo de movimiento (CARGA, PAGO, AJUSTE)
  - Datos de ejemplo para demostración
  - Interfaz lista para integración con endpoint futuro

## 🏗️ Modelos de Datos

### Billetera (`lib/models/billetera.dart`)
```dart
class Billetera {
  final int id;
  final int clienteId;
  final double saldo;
  final String moneda;
}

class BilleteraSaldoResponse {
  final bool ok;
  final int billeteraId;
  final String saldo;
  final String moneda;
}

class BilleteraCargaRequest {
  final int billeteraId;
  final double monto;
  final String concepto;
}
```

### Movimiento (`lib/models/movimiento.dart`)
```dart
class Movimiento {
  final int id;
  final int billeteraId;
  final String tipo; // CARGA, PAGO, AJUSTE
  final double monto;
  final String? concepto;
  final DateTime fecha;
}
```

## 🔧 Servicios

### BilleteraService (`lib/services/billetera_service.dart`)
- **Endpoints integrados**:
  - `GET /billeteras/{cliente_id}/saldo` - Consultar saldo
  - `POST /billeteras/cargar` - Cargar saldo
- **Funcionalidades adicionales**:
  - Simulación de escaneo QR
  - Decodificación de JWT para obtener cliente_id
  - Manejo de errores y logging

### AuthService (actualizado)
- **Nuevos métodos**:
  - `getClienteIdFromToken()` - Extraer ID del cliente del JWT
  - `getCurrentCliente()` - Obtener información completa del cliente

## 🎨 Diseño y UX

### Paleta de Colores
- **Primario**: `#197B9C` (Azul turquesa)
- **Secundario**: `#0B0530` (Azul oscuro)
- **Gradientes**: Combinación de colores primarios
- **Estados**: Verde para éxito, rojo para errores

### Componentes UI
- Cards con elevación y bordes redondeados
- Gradientes en elementos principales
- Iconografía consistente
- Animaciones de carga y transiciones suaves
- RefreshIndicator para actualización manual

## 📱 Navegación

### Estructura de Navegación
```
ClienteLoginPage
    ↓ (después del login)
ClienteDashboardPage
├── Inicio (Tab 0)
├── Billetera (Tab 1)
├── Movimientos (Tab 2)
└── Perfil (Tab 3)
```

### Flujo de Datos
1. Login exitoso → Obtener información del cliente
2. Cargar saldo inicial desde backend
3. Navegación entre secciones manteniendo estado
4. Actualización de saldo en tiempo real

## 🔗 Integración con Backend

### Endpoints Utilizados
- `POST /clientes/login` - Autenticación
- `GET /billeteras/{cliente_id}/saldo` - Consultar saldo
- `POST /billeteras/cargar` - Recargar saldo

### Manejo de Autenticación
- Tokens JWT almacenados en memoria
- Headers de autorización automáticos
- Decodificación de payload para obtener información del usuario

## 🚀 Funcionalidades Futuras Preparadas

### 1. Historial Completo de Movimientos
- Endpoint para obtener movimientos: `GET /billeteras/{billetera_id}/movimientos`
- Filtros por fecha, tipo, monto
- Paginación de resultados

### 2. Configuración de Perfil
- Edición de información personal
- Cambio de contraseña
- Configuración de notificaciones

### 3. Sistema de Notificaciones
- Notificaciones push para transacciones
- Alertas de saldo bajo
- Confirmaciones de recarga

## 🛠️ Instalación y Uso

### Dependencias Requeridas
Las siguientes dependencias ya están incluidas en `pubspec.yaml`:
- `http` - Para llamadas a API
- `location` - Para geolocalización
- Material Design - Para UI

### Ejecutar la Aplicación
1. Asegurar que el backend esté ejecutándose en `http://10.0.2.2:8000`
2. Ejecutar `flutter run` en el directorio del proyecto
3. Usar credenciales válidas para iniciar sesión

## 📋 Testing

### Datos de Prueba
- La simulación QR genera montos aleatorios predefinidos
- Los movimientos muestran datos de ejemplo
- El saldo se actualiza en tiempo real después de recargas

### Escenarios de Prueba
1. Login exitoso → Verificar carga de saldo
2. Simulación QR → Confirmar actualización de saldo
3. Navegación entre secciones → Verificar mantención de estado
4. Logout → Confirmar limpieza de datos

## 🔒 Seguridad

### Consideraciones Implementadas
- Validación de tokens JWT
- Autorización por cliente (solo puede ver su propio saldo)
- Confirmación antes de operaciones críticas
- Manejo seguro de errores sin exposición de datos sensibles

---

**Nota**: Este sistema está preparado para integrarse completamente con el backend existente y es fácilmente extensible para futuras funcionalidades.

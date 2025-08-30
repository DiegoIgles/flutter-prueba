# Integración con APIs del Backend

## 🔌 APIs Implementadas

La aplicación Flutter ahora está completamente integrada con el backend FastAPI para:

### ✅ **Cliente**
- **Login**: `POST /api/clientes/login`
- **Registro**: `POST /api/clientes/register`

### ✅ **Chofer**  
- **Login**: `POST /api/login`
- **Registro**: No disponible (solo superusuarios pueden crear choferes)

## 📱 Funcionalidades Implementadas

### 1. **Pantalla de Selección de Usuario**
- Permite elegir entre Cliente o Chofer
- Navega a la pantalla de login correspondiente

### 2. **Pantalla de Login**
- **Validación de email**: Formato correcto de email
- **Conexión con APIs**: Consumo real de endpoints del backend
- **Manejo de errores**: Mensajes específicos para diferentes errores
- **Diferenciación por tipo**: Lógica diferente para clientes y choferes

### 3. **Pantalla de Registro (Solo Clientes)**
- **Campos completos**: Nombre, apellido, email, teléfono, contraseña
- **Validaciones robustas**: Email, teléfono boliviano, contraseña segura
- **Confirmación de contraseña**: Validación en tiempo real
- **Registro automático**: Navega al login después del registro exitoso

### 4. **Manejo de Respuestas del Servidor**
- **Tokens de autenticación**: Preparado para JWT (no implementado aún)
- **Mensajes de bienvenida**: Personalizados con nombre del usuario
- **Errores específicos**: Manejo de errores 400, 401, 500, etc.
- **Timeouts**: Manejo de conexiones lentas o perdidas

## 🔧 Configuración

### Archivo: `lib/services/api_config.dart`
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

**⚠️ IMPORTANTE**: Cambia esta URL según tu configuración:
- **Desarrollo local**: `http://localhost:8000/api`
- **Servidor remoto**: `https://tu-servidor.com/api`
- **Emulador Android**: `http://10.0.2.2:8000/api`

## 📊 Estructura de Archivos Nuevos

```
lib/
├── models/
│   ├── cliente.dart          # Modelos para Cliente
│   └── chofer.dart           # Modelos para Chofer
├── services/
│   ├── api_config.dart       # Configuración de URLs
│   └── auth_service.dart     # Servicios de autenticación
└── screens/
    ├── register_screen.dart  # Pantalla de registro
    ├── login_screen.dart     # Actualizada con APIs
    └── ... (otras pantallas)
```

## 🚀 Cómo Probar

### 1. **Preparar el Backend**
```bash
# En el directorio backend-service
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 2. **Ejecutar la App Flutter**
```bash
# En el directorio flutter-prueba
flutter run
```

### 3. **Flujo de Prueba para Clientes**
1. Seleccionar "Cliente" en la pantalla inicial
2. Ir a "Registrarse" 
3. Completar el formulario de registro
4. Usar las credenciales para hacer login

### 4. **Flujo de Prueba para Choferes**
1. Seleccionar "Chofer" en la pantalla inicial
2. Usar credenciales de chofer existentes en la BD
3. No hay opción de registro (solo superusuarios)

## ⚡ Validaciones Implementadas

### **Email**
- Formato válido: `usuario@dominio.com`
- Conversión automática a minúsculas

### **Contraseña**
- Mínimo 6 caracteres
- Confirmación requerida en registro

### **Teléfono (Opcional para Clientes)**
- Formato boliviano: `70123456` o `+59170123456`
- Números que empiecen con 6 o 7

### **Campos Obligatorios**
- Nombre y apellido (mínimo 2 caracteres)
- Email válido
- Contraseña segura

## 🔐 Seguridad

### **Datos Sensibles**
- Las contraseñas no se almacenan en la app
- Los tokens se preparan para almacenamiento seguro
- Validación en cliente Y servidor

### **Manejo de Errores**
- No se muestran errores técnicos al usuario
- Mensajes amigables y específicos
- Logs de errores para debugging

## 📋 Próximos Pasos

### **Funcionalidades Pendientes**
- [ ] Almacenamiento de tokens JWT
- [ ] Persistencia de sesión
- [ ] Refresh tokens
- [ ] Perfil de usuario
- [ ] Logout funcional
- [ ] Recuperación de contraseña

### **Mejoras Sugeridas**
- [ ] Indicadores de carga más detallados
- [ ] Validación de campos en tiempo real
- [ ] Autocompletado de formularios
- [ ] Integración con biometría
- [ ] Modo offline

## 🐛 Troubleshooting

### **Error de Conexión**
- Verificar que el backend esté ejecutándose
- Comprobar la URL en `api_config.dart`
- Revisar permisos de red en Android

### **Error 401 Unauthorized**
- Credenciales incorrectas
- Usuario no existe en la base de datos

### **Error 422 Validation Error**
- Datos enviados no cumplen con el schema
- Revisar formato de email o campos obligatorios

### **Timeout**
- Conexión lenta o servidor no responde
- Aumentar timeout en `api_config.dart`

---

## 📞 Soporte

Para problemas con la integración:
1. Verificar logs de Flutter: `flutter logs`
2. Revisar logs del backend FastAPI
3. Usar herramientas como Postman para probar endpoints directamente

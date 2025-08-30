import 'package:flutter/material.dart';
import '../models/login_request.dart';
import '../models/cliente_create.dart';
import '../services/auth_service.dart';
import 'cliente_dashboard_page.dart';

class ClienteLoginPage extends StatefulWidget {
  const ClienteLoginPage({super.key});

  @override
  State<ClienteLoginPage> createState() => _ClienteLoginPageState();
}

class _ClienteLoginPageState extends State<ClienteLoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _isLoginMode = true; // true para login, false para registro

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final String email = emailCtrl.text.trim();
    final String password = passCtrl.text.trim();

    print('🔑 Intentando login con:');
    print('📧 Email: $email');
    print('🔐 Password: $password');

    try {
      final auth = AuthService();
      final tokenRes = await auth.loginCliente(
        LoginRequest(email: email, password: password),
      );

      print('✅ Login exitoso');
      print('🪪 Access Token: ${tokenRes.accessToken}');
      print('🧾 Token Type: ${tokenRes.tokenType}');

      // Obtener información del cliente
      final clienteInfo = await auth.getCurrentCliente();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClienteDashboardPage(
            token: tokenRes.accessToken,
            cliente: clienteInfo,
          ),
        ),
      );
    } catch (e) {
      print('❌ Login fallido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login fallido: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final String nombre = nombreCtrl.text.trim();
    final String apellido = apellidoCtrl.text.trim();
    final String email = emailCtrl.text.trim();
    final String password = passCtrl.text.trim();
    final String? telefono =
        telefonoCtrl.text.trim().isEmpty ? null : telefonoCtrl.text.trim();

    print('📝 Intentando registro con:');
    print('👤 Nombre: $nombre');
    print('👤 Apellido: $apellido');
    print('📧 Email: $email');
    print('📱 Teléfono: $telefono');

    try {
      final auth = AuthService();
      final cliente = await auth.registerCliente(
        ClienteCreate(
          nombre: nombre,
          apellido: apellido,
          email: email,
          password: password,
          telefono: telefono,
        ),
      );

      print('✅ Registro exitoso');
      print('👤 Cliente: ${cliente.nombre} ${cliente.apellido}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Ahora puedes iniciar sesión.'),
          backgroundColor: Colors.green,
        ),
      );

      // Cambiar a modo login y limpiar formularios
      setState(() {
        _isLoginMode = true;
        nombreCtrl.clear();
        apellidoCtrl.clear();
        telefonoCtrl.clear();
        // Mantenemos email y password para facilitar el login
      });
    } catch (e) {
      print('❌ Registro fallido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro fallido: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      // Limpiar campos al cambiar de modo
      emailCtrl.clear();
      passCtrl.clear();
      nombreCtrl.clear();
      apellidoCtrl.clear();
      telefonoCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const topColor = Color(0xFF0B0530); // Color azul oscuro topbar
    const gradientTop = Color(0xFFEDEDED);
    const gradientBottom = Color(0xFF8B8B8B);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: topColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientTop, gradientBottom],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLoginMode ? 'Iniciar sesión' : 'Registrarse',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              constraints: const BoxConstraints(maxHeight: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campos adicionales para registro
                      if (!_isLoginMode) ...[
                        TextFormField(
                          controller: nombreCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Nombre',
                            border: UnderlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Ingrese nombre' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: apellidoCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Apellido',
                            border: UnderlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Ingrese apellido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Campos comunes
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Correo electrónico',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingrese correo';
                          if (!v.contains('@'))
                            return 'Ingrese un correo válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Contraseña',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Ingrese contraseña';
                          if (!_isLoginMode && v.length < 6)
                            return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),

                      // Campo teléfono solo para registro
                      if (!_isLoginMode) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Teléfono (opcional)',
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading
                            ? null
                            : (_isLoginMode ? _login : _register),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF197B9C),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _isLoginMode ? 'Ingresar' : 'Registrarse',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loading ? null : _toggleMode,
                        child: Text(
                          _isLoginMode
                              ? '¿No tienes cuenta? Regístrate'
                              : '¿Ya tienes cuenta? Inicia sesión',
                          style: TextStyle(
                            color: const Color(0xFF197B9C),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Bienvenido',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

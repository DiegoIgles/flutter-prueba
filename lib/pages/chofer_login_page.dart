import 'package:flutter/material.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';
import 'chofer_dashboard_page.dart';

class ChoferLoginPage extends StatefulWidget {
  const ChoferLoginPage({super.key});

  @override
  State<ChoferLoginPage> createState() => _ChoferLoginPageState();
}

class _ChoferLoginPageState extends State<ChoferLoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _loginChofer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    try {
      final auth = AuthService();
      final tokenRes = await auth.loginChofer(
        LoginRequest(email: email, password: password),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChoferDashboardPage(token: tokenRes.accessToken),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login de chofer fallido: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const topColor = Color(0xFF0B0530);
    const gradientTop = Color(0xFFEDEDED);
    const gradientBottom = Color(0xFF8B8B8B);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: topColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('', style: TextStyle(color: Colors.white)),
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
            const Text('Iniciar sesión',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Correo electrónico',
                        border: UnderlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingrese correo' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Contraseña',
                        border: UnderlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingrese contraseña' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _loginChofer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A), // morado
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Ingresar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Bienvenido, chofer',
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

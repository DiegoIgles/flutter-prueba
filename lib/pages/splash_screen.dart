import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _rotationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Animación de desvanecimiento
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Animación de escala
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Animación de deslizamiento
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Animación de rotación suave
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // Vibración suave al inicio (si está disponible)
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // Ignorar si no está disponible
    }

    // Secuencia de animaciones
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();
    _rotationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _slideController.forward();

    // Esperar que todas las animaciones terminen
    await Future.delayed(const Duration(milliseconds: 2800));
    
    // Vibración final
    try {
      HapticFeedback.selectionClick();
    } catch (e) {
      // Ignorar si no está disponible
    }
    
    // Navegar a la página principal
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B0530), // Azul oscuro
                  Color(0xFF4F46E5), // Púrpura principal
                  Color(0xFF197B9C), // Azul medio
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Partículas flotantes
          _buildFloatingParticles(),
          
          // Contenido principal
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo principal animado con efecto de pulso
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value * 0.1,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Efecto de pulso exterior
                                      Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                      // Logo principal
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                            BoxShadow(
                                              color: const Color(0xFF4F46E5).withOpacity(0.4),
                                              blurRadius: 30,
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.directions_bus_filled,
                                          size: 60,
                                          color: Color(0xFF4F46E5),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Título animado
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'TransApp',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu transporte, tu ciudad',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Iconos de transporte animados
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTransportIcon(Icons.directions_bus, 0),
                        const SizedBox(width: 20),
                        _buildTransportIcon(Icons.directions_subway, 200),
                        const SizedBox(width: 20),
                        _buildTransportIcon(Icons.local_taxi, 400),
                        const SizedBox(width: 20),
                        _buildTransportIcon(Icons.train, 600),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 80),
                
                // Indicador de carga
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Preparando tu viaje...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value * 0.6,
          child: Stack(
            children: [
              // Partículas flotantes
              ...List.generate(8, (index) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                return Positioned(
                  left: (index * 50.0) % screenWidth,
                  top: (index * 80.0) % screenHeight,
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 2000 + (index * 200)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -value * 20),
                        child: Opacity(
                          opacity: (1 - value) * 0.7,
                          child: Container(
                            width: 6 + (index % 3) * 2,
                            height: 6 + (index % 3) * 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransportIcon(IconData icon, int delay) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 1000 + delay),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

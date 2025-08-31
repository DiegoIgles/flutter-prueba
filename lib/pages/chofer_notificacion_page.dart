import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chofer_notificacion_service.dart';

class ChoferNotificacionPage extends StatelessWidget {
  const ChoferNotificacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Consumer<ChoferNotificacionService>(
          builder: (context, notiService, _) {
            final notis = notiService.notificaciones;
            if (notis.isEmpty) return const SizedBox.shrink();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(notis.length, (i) {
                final n = notis[i];
                return _AnimatedNotiCard(
                  key: ValueKey(n.id),
                  noti: n,
                  onClose: () => notiService.clearNotificacion(n.id),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

/// Colores base (verde éxito). Ajusta si quieres combinar con tu paleta.
const _successStart = Color(0xFF16A34A); // green-600
const _successEnd   = Color(0xFF0E7A3C); // green-700
const _surface      = Colors.white;

class _AnimatedNotiCard extends StatefulWidget {
  final ChoferNotificacion noti;
  final VoidCallback onClose;
  const _AnimatedNotiCard({super.key, required this.noti, required this.onClose});

  @override
  State<_AnimatedNotiCard> createState() => _AnimatedNotiCardState();
}

class _AnimatedNotiCardState extends State<_AnimatedNotiCard> with TickerProviderStateMixin {
  late final AnimationController _inOutCtrl;   // entra/sale
  late final AnimationController _lifeCtrl;    // duración visible (barra de vida)
  late final AnimationController _pulseCtrl;   // pulso alrededor del icono

  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _iconPop;       // rebote de icono

  static const _enterDuration = Duration(milliseconds: 700);
  static const _exitDuration  = Duration(milliseconds: 350);
  static const _lifeDuration  = Duration(milliseconds: 3600);

  @override
  void initState() {
    super.initState();

    _inOutCtrl = AnimationController(
      vsync: this,
      duration: _enterDuration,
      reverseDuration: _exitDuration,
    );

    _lifeCtrl = AnimationController(
      vsync: this,
      duration: _lifeDuration,
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.1),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_inOutCtrl);

    _fade = CurvedAnimation(parent: _inOutCtrl, curve: Curves.easeInOut);

    _iconPop = CurvedAnimation(
      parent: _inOutCtrl,
      curve: const Interval(0.15, 0.55, curve: Curves.elasticOut),
    );

    // Secuencia: entra -> corre vida -> sale -> onClose
    _inOutCtrl.forward();
    _pulseCtrl.repeat();
    _lifeCtrl.forward();

    _lifeCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _inOutCtrl.reverse();
      }
    });

    _inOutCtrl.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        _pulseCtrl.stop();
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _inOutCtrl.dispose();
    _lifeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _closeNow() {
    if (_inOutCtrl.status != AnimationStatus.reverse) {
      _inOutCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final maxWidth = w.clamp(0, 720.0); // ocupa más ancho; hasta 720px en tablets
    final horizontal = w < 380 ? 10.0 : 12.0;

    return Dismissible(
      key: widget.key as Key,
      direction: DismissDirection.up,
      onDismissed: (_) => _closeNow(),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: EdgeInsets.only(top: 10, left: horizontal, right: horizontal),
            child: Material(
              color: Colors.transparent,
              elevation: 18,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: maxWidth.toDouble(),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [_successStart, _successEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Barra de vida (tiempo restante)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _lifeCtrl,
                        builder: (_, __) {
                          final rem = (1.0 - _lifeCtrl.value).clamp(0.0, 1.0);
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 3,
                                width: maxWidth * rem,
                                color: _surface.withOpacity(0.85),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Contenido
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icono con pulso
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseCtrl,
                                  builder: (_, __) {
                                    final t = _pulseCtrl.value; // 0..1
                                    final scale = 1.0 + (0.9 * t);
                                    final opacity = (1.0 - t).clamp(0.0, 1.0) * 0.35;
                                    return Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _surface.withOpacity(opacity),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ScaleTransition(
                                  scale: _iconPop,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _surface,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: const Icon(
                                      Icons.check_circle_rounded, // icono de “bien”
                                      color: _successStart,
                                      size: 34,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Textos
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.noti.clienteNombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Te ha pagado ${widget.noti.monto.toStringAsFixed(2)} BOB',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Botón cerrar
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                            splashRadius: 22,
                            onPressed: _closeNow,
                            tooltip: 'Cerrar',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

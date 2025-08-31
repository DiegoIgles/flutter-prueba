import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chofer_billetera_provider.dart';

class ChoferBilleteraPage extends StatefulWidget {
  const ChoferBilleteraPage({super.key});

  @override
  State<ChoferBilleteraPage> createState() => _ChoferBilleteraPageState();
}

class _ChoferBilleteraPageState extends State<ChoferBilleteraPage> {
  bool _loadingAction = false;

  @override
  void initState() {
    super.initState();
    // Cargar saldo si no está disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ChoferBilleteraProvider>(context, listen: false);
      if (provider.saldo == null && !provider.loadingSaldo) {
        provider.cargarSaldo();
      }
    });
  }

  Future<void> _cargarSaldo() async {
    await Provider.of<ChoferBilleteraProvider>(context, listen: false)
        .cargarSaldo();
  }

  Future<void> _simularGananciaViaje() async {
    setState(() => _loadingAction = true);

    try {
      // Simular ganancia de viaje
      final provider =
          Provider.of<ChoferBilleteraProvider>(context, listen: false);

      // Mostrar diálogo de proceso
      _mostrarDialogoProceso();

      // Simular tiempo de procesamiento
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar diálogo de proceso
      if (mounted) Navigator.of(context).pop();

      // Mostrar confirmación de ganancia
      final confirmar = await _mostrarDialogoGanancia();

      if (confirmar == true) {
        await provider.cargarCreditos(
          monto: 2.20, // Ganancia después de comisión
          concepto: 'Ganancia por viaje completado',
        );

        _mostrarExito(
            '¡Ganancia registrada! Nuevo saldo: ${provider.saldo?.saldo ?? '0.00'} BOB');
      }
    } catch (e) {
      _mostrarError('Error al procesar ganancia: $e');
    } finally {
      setState(() => _loadingAction = false);
    }
  }

  void _mostrarDialogoProceso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF197B9C),
            ),
            const SizedBox(height: 16),
            const Text('Procesando ganancia del viaje...'),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF197B9C), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_bus,
                size: 60,
                color: Color(0xFF197B9C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _mostrarDialogoGanancia() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Viaje Completado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¡Felicidades! Has completado un viaje exitosamente.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF197B9C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetalleFila('Tarifa del viaje:', '2.30 BOB'),
                  const Divider(),
                  _buildDetalleFila('Comisión de la app:', '0.10 BOB',
                      color: Colors.red),
                  const Divider(),
                  _buildDetalleFila('Tu ganancia:', '2.20 BOB',
                      color: const Color(0xFF197B9C), isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nuestro modelo: por cada 2.30 BOB que cobras, nosotros nos quedamos con 0.10 BOB.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF197B9C),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleFila(String label, String valor,
      {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cargarSaldo,
        color: const Color(0xFF197B9C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de saldo principal
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF197B9C), Color(0xFF0B0530)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mi Billetera - Chofer',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Consumer<ChoferBilleteraProvider>(
                            builder: (context, provider, child) {
                              return IconButton(
                                onPressed:
                                    provider.loadingSaldo ? null : _cargarSaldo,
                                icon: provider.loadingSaldo
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Consumer<ChoferBilleteraProvider>(
                        builder: (context, provider, child) {
                          return Text(
                            provider.loadingSaldo
                                ? 'Cargando...'
                                : '${provider.saldo?.saldo ?? '0.00'} ${provider.saldo?.moneda ?? 'BOB'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ganancias acumuladas',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de simular ganancia
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadingAction ? null : _simularGananciaViaje,
                  icon: _loadingAction
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.directions_bus),
                  label: Text(
                    _loadingAction
                        ? 'Procesando...'
                        : 'Simular Ganancia de Viaje',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF197B9C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Información del modelo de negocio
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF197B9C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: Color(0xFF197B9C),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Modelo de Negocio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildModeloFila('💰 Tarifa por viaje', '2.30 BOB'),
                            const SizedBox(height: 8),
                            _buildModeloFila(
                                '📱 Comisión de la app', '0.10 BOB'),
                            const Divider(),
                            _buildModeloFila('✅ Tu ganancia', '2.20 BOB',
                                color: const Color(0xFF197B9C), isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Como chofer partner, por cada viaje completado recibes el 95.7% de la tarifa. '
                        'Nosotros mantenemos una pequeña comisión del 4.3% para mantener y mejorar la plataforma.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Información de la billetera
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de la billetera',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<ChoferBilleteraProvider>(
                        builder: (context, provider, child) {
                          if (provider.saldo != null) {
                            return Column(
                              children: [
                                _buildInfoRow(
                                  'ID de Billetera',
                                  provider.saldo!.billeteraId.toString(),
                                  Icons.wallet,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Moneda',
                                  provider.saldo!.moneda,
                                  Icons.monetization_on,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Estado',
                                  'Activa',
                                  Icons.check_circle,
                                  valueColor: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Tipo',
                                  'Chofer Partner',
                                  Icons.local_taxi,
                                  valueColor: const Color(0xFF197B9C),
                                ),
                              ],
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'Cargando información...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeloFila(String label, String valor,
      {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF197B9C),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

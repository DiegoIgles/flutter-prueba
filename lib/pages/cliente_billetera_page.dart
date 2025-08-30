import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/billetera_service.dart';
import '../providers/billetera_provider.dart';
import '../models/billetera.dart';

class ClienteBilleteraPage extends StatefulWidget {
  const ClienteBilleteraPage({super.key});

  @override
  State<ClienteBilleteraPage> createState() => _ClienteBilleteraPageState();
}

class _ClienteBilleteraPageState extends State<ClienteBilleteraPage> {
  final BilleteraService _billeteraService = BilleteraService();
  bool _loadingCarga = false;

  @override
  void initState() {
    super.initState();
    // Cargar saldo si no está disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BilleteraProvider>(context, listen: false);
      if (provider.saldo == null && !provider.loadingSaldo) {
        provider.cargarSaldo();
      }
    });
  }

  Future<void> _cargarSaldo() async {
    await Provider.of<BilleteraProvider>(context, listen: false).cargarSaldo();
  }

  Future<void> _simularEscaneoQR() async {
    setState(() => _loadingCarga = true);

    try {
      // Mostrar diálogo de "escaneando"
      _mostrarDialogoEscaneo();

      // Simular escaneo de QR
      final monto = await _billeteraService.simularEscaneoQR();

      // Cerrar diálogo de escaneo
      if (mounted) Navigator.of(context).pop();

      // Mostrar diálogo de confirmación
      final confirmar = await _mostrarDialogoConfirmacion(monto);

      if (confirmar == true) {
        // Realizar la carga usando el provider
        final provider = Provider.of<BilleteraProvider>(context, listen: false);
        await provider.cargarCreditos(
          monto: monto,
          concepto: 'Recarga mediante código QR',
        );

        // Mostrar mensaje de éxito
        _mostrarExito('¡Recarga exitosa! Nuevo saldo: ${provider.saldo?.saldo ?? '0.00'} BOB');
      }
    } catch (e) {
      _mostrarError('Error en la recarga: $e');
    } finally {
      setState(() => _loadingCarga = false);
    }
  }

  void _mostrarDialogoEscaneo() {
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
            const Text('Escaneando código QR...'),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF197B9C), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 60,
                color: Color(0xFF197B9C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion(double monto) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar recarga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas proceder con la siguiente recarga?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF197B9C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Monto:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${monto.toStringAsFixed(2)} BOB',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF197B9C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF197B9C),
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
                            'Mi Billetera',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Consumer<BilleteraProvider>(
                            builder: (context, billeteraProvider, child) {
                              return IconButton(
                                onPressed: billeteraProvider.loadingSaldo
                                    ? null
                                    : _cargarSaldo,
                                icon: billeteraProvider.loadingSaldo
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
                      Consumer<BilleteraProvider>(
                        builder: (context, billeteraProvider, child) {
                          return Text(
                            billeteraProvider.loadingSaldo
                                ? 'Cargando...'
                                : '${billeteraProvider.saldo?.saldo ?? '0.00'} ${billeteraProvider.saldo?.moneda ?? 'BOB'}',
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
                        'Saldo disponible',
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

              // Botón de cargar saldo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadingCarga ? null : _simularEscaneoQR,
                  icon: _loadingCarga
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner),
                  label: Text(
                    _loadingCarga
                        ? 'Procesando...'
                        : 'Escanear QR para recargar',
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
                      Consumer<BilleteraProvider>(
                        builder: (context, billeteraProvider, child) {
                          if (billeteraProvider.saldo != null) {
                            return Column(
                              children: [
                                _buildInfoRow(
                                  'ID de Billetera',
                                  billeteraProvider.saldo!.billeteraId.toString(),
                                  Icons.wallet,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Moneda',
                                  billeteraProvider.saldo!.moneda,
                                  Icons.monetization_on,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Estado',
                                  'Activa',
                                  Icons.check_circle,
                                  valueColor: Colors.green,
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

              const SizedBox(height: 24),

              // Instrucciones de uso
              Card(
                elevation: 2,
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
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF197B9C),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Cómo recargar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Presiona "Escanear QR para recargar"\n'
                        '2. Espera a que se detecte el código QR\n'
                        '3. Confirma el monto mostrado\n'
                        '4. Tu saldo se actualizará automáticamente',
                        style: TextStyle(
                          color: Colors.grey,
                          height: 1.5,
                        ),
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

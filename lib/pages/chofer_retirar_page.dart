import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chofer_billetera_provider.dart';
import '../services/chofer_billetera_service.dart';

class ChoferRetirarPage extends StatefulWidget {
  const ChoferRetirarPage({super.key});

  @override
  State<ChoferRetirarPage> createState() => _ChoferRetirarPageState();
}

class _ChoferRetirarPageState extends State<ChoferRetirarPage> {
  final ChoferBilleteraService _billeteraService = ChoferBilleteraService();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _conceptoController = TextEditingController();
  bool _loadingRetiro = false;
  String _metodoPago = 'banco';

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

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  Future<void> _cargarSaldo() async {
    await Provider.of<ChoferBilleteraProvider>(context, listen: false)
        .cargarSaldo();
  }

  Future<void> _simularRetiroRapido() async {
    setState(() => _loadingRetiro = true);

    try {
      // Mostrar diálogo de simulación
      _mostrarDialogoSimulacion();

      // Simular tiempo de procesamiento
      final monto = await _billeteraService.simularMontoRetiro();
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar diálogo de simulación
      if (mounted) Navigator.of(context).pop();

      // Mostrar diálogo de confirmación
      final confirmar =
          await _mostrarDialogoConfirmacion(monto, 'Retiro rápido');

      if (confirmar == true) {
        final provider =
            Provider.of<ChoferBilleteraProvider>(context, listen: false);
        await provider.retirarSaldo(
          monto: monto,
          concepto: 'Retiro rápido - $_metodoPago',
        );

        _mostrarExito(
            '¡Retiro procesado! Nuevo saldo: ${provider.saldo?.saldo ?? '0.00'} BOB');
      }
    } catch (e) {
      _mostrarError('Error en el retiro: $e');
    } finally {
      setState(() => _loadingRetiro = false);
    }
  }

  Future<void> _realizarRetiroPersonalizado() async {
    if (!_validarFormulario()) return;

    setState(() => _loadingRetiro = true);

    try {
      final monto = double.parse(_montoController.text);
      final concepto = _conceptoController.text.trim().isEmpty
          ? 'Retiro manual - $_metodoPago'
          : _conceptoController.text.trim();

      // Mostrar diálogo de procesamiento
      _mostrarDialogoProcesamiento();

      // Simular tiempo de procesamiento
      await Future.delayed(const Duration(seconds: 1));

      // Cerrar diálogo de procesamiento
      if (mounted) Navigator.of(context).pop();

      final provider =
          Provider.of<ChoferBilleteraProvider>(context, listen: false);
      await provider.retirarSaldo(monto: monto, concepto: concepto);

      // Limpiar formulario
      _montoController.clear();
      _conceptoController.clear();

      _mostrarExito(
          '¡Retiro procesado! Nuevo saldo: ${provider.saldo?.saldo ?? '0.00'} BOB');
    } catch (e) {
      _mostrarError('Error en el retiro: $e');
    } finally {
      setState(() => _loadingRetiro = false);
    }
  }

  bool _validarFormulario() {
    if (_montoController.text.trim().isEmpty) {
      _mostrarError('Ingresa el monto a retirar');
      return false;
    }

    final monto = double.tryParse(_montoController.text);
    if (monto == null || monto <= 0) {
      _mostrarError('El monto debe ser mayor a 0');
      return false;
    }

    final provider =
        Provider.of<ChoferBilleteraProvider>(context, listen: false);
    final saldoActual = double.tryParse(provider.saldo?.saldo ?? '0') ?? 0;

    if (monto > saldoActual) {
      _mostrarError('Saldo insuficiente');
      return false;
    }

    return true;
  }

  void _mostrarDialogoSimulacion() {
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
            const Text('Procesando retiro rápido...'),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF197B9C), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance,
                size: 60,
                color: Color(0xFF197B9C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoProcesamiento() {
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
            const Text('Procesando retiro...'),
          ],
        ),
      ),
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion(double monto, String tipo) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar $tipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas proceder con el siguiente retiro?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF197B9C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetalleFila(
                      'Monto:', '${monto.toStringAsFixed(2)} BOB'),
                  const SizedBox(height: 8),
                  _buildDetalleFila('Método:', _getMetodoPagoText()),
                  const SizedBox(height: 8),
                  _buildDetalleFila('Tiempo:', _getTiempoEstimado()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tiempo: ${_getTiempoEstimado()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
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

  Widget _buildDetalleFila(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _getMetodoPagoText() {
    switch (_metodoPago) {
      case 'banco':
        return 'Banco';
      case 'movil':
        return 'Móvil';
      case 'efectivo':
        return 'Efectivo';
      default:
        return 'N/A';
    }
  }

  String _getTiempoEstimado() {
    switch (_metodoPago) {
      case 'banco':
        return '24-48h';
      case 'movil':
        return '2-4h';
      case 'efectivo':
        return '30min';
      default:
        return '24h';
    }
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
              // Tarjeta de saldo actual
              Consumer<ChoferBilleteraProvider>(
                builder: (context, provider, child) {
                  return Card(
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
                          const Text(
                            'Saldo disponible para retiro',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.loadingSaldo
                                ? 'Cargando...'
                                : '${provider.saldo?.saldo ?? '0.00'} ${provider.saldo?.moneda ?? 'BOB'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
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
                  );
                },
              ),

              const SizedBox(height: 24),

              // Botón de retiro rápido
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadingRetiro ? null : _simularRetiroRapido,
                  icon: _loadingRetiro
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.flash_on),
                  label: Text(
                    _loadingRetiro ? 'Procesando...' : 'Retiro Rápido',
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

              const SizedBox(height: 16),

              // Separador
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'O personaliza tu retiro',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),

              const SizedBox(height: 24),

              // Formulario de retiro personalizado
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                              Icons.tune,
                              color: Color(0xFF197B9C),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Retiro Personalizado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Monto
                      TextFormField(
                        controller: _montoController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Monto a retirar (BOB)',
                          prefixIcon:
                              const Icon(Icons.money, color: Color(0xFF197B9C)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF197B9C), width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Método de pago
                      DropdownButtonFormField<String>(
                        isExpanded: true ,
                        value: _metodoPago,
                        decoration: InputDecoration(
                          labelText: 'Método de retiro',
                          prefixIcon: const Icon(Icons.payment,
                              color: Color(0xFF197B9C)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF197B9C), width: 2),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'banco',
                            child: Text(
                              '🏦 Transferencia bancaria',
                              overflow: TextOverflow.visible,
                              softWrap: true,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'movil',
                            child: Text('📱 Banca móvil'),
                          ),
                          DropdownMenuItem(
                            value: 'efectivo',
                            child: Text('💵 Punto de efectivo'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _metodoPago = value ?? 'banco';
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Concepto (opcional)
                      TextFormField(
                        controller: _conceptoController,
                        decoration: InputDecoration(
                          labelText: 'Concepto (opcional)',
                          prefixIcon:
                              const Icon(Icons.note, color: Color(0xFF197B9C)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF197B9C), width: 2),
                          ),
                          hintText: 'Ej: Pago de gastos personales',
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 20),

                      // Información del método seleccionado
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tiempo estimado: ${_getTiempoEstimado()}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botón de retiro
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loadingRetiro
                              ? null
                              : _realizarRetiroPersonalizado,
                          icon: const Icon(Icons.send),
                          label: const Text('Procesar Retiro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B0530),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Información importante
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
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Información importante',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Monto mínimo de retiro: 10.00 BOB\n'
                        '• Los retiros se procesan en días hábiles\n'
                        '• Verifica tu información de pago antes de confirmar\n'
                        '• Conserva el comprobante de tu transacción',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
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
}

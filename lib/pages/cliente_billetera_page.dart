import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/billetera_provider.dart';
import '../services/billetera_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class ClienteBilleteraPage extends StatefulWidget {
  const ClienteBilleteraPage({super.key});

  @override
  State<ClienteBilleteraPage> createState() => _ClienteBilleteraPageState();
}

class _ClienteBilleteraPageState extends State<ClienteBilleteraPage> {
  final BilleteraService _billeteraService = BilleteraService();

  final _montoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loadingBoton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BilleteraProvider>(context, listen: false);
      if (provider.saldo == null && !provider.loadingSaldo) {
        provider.cargarSaldo();
      }
    });
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarSaldo() async {
    await Provider.of<BilleteraProvider>(context, listen: false).cargarSaldo();
  }

  // 1) Pide el monto y, si es válido, inicia la recarga con QR y abre el modal
  Future<void> _pedirMontoYMostrarQr() async {
    _montoCtrl.text = '';
    final monto = await showDialog<double?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monto a recargar'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _montoCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              hintText: 'Ej: 10.00',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa un monto';
              final x = double.tryParse(v);
              if (x == null) return 'Monto no válido';
              if (x <= 0) return 'El monto debe ser mayor a 0';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, double.parse(_montoCtrl.text.trim()));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF197B9C)),
            child:
                const Text('Generar QR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (monto == null) return;

    setState(() => _loadingBoton = true);
    final provider = Provider.of<BilleteraProvider>(context, listen: false);

    try {
      // 2) Iniciar recarga (esto llama /qr/generar y arranca el polling en el provider)
      await provider.iniciarRecargaConQr(
        monto: monto,
        vigencia: "0/00:05",
        usoUnico: true,
        intervalo: const Duration(seconds: 3),
      );

      // 3) Mostrar modal con el QR mientras el provider hace polling a /qr/verificar
      if (!mounted) return;
      await _mostrarModalQr();
    } catch (e) {
      if (!mounted) return;
      _snack('Error generando QR: $e', error: true);
    } finally {
      if (mounted) setState(() => _loadingBoton = false);
    }
  }

  Future<void> _mostrarModalQr() async {
    final provider = Provider.of<BilleteraProvider>(context, listen: false);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Consumer<BilleteraProvider>(
          builder: (context, p, _) {
            final estado = p.qrEstado.toLowerCase();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Text(
                  'Escanea con tu app bancaria',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // QR
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF197B9C), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: p.qrDataUrl != null
                      ? Image.memory(
                          base64Decode(p.qrDataUrl!.split(',').last),
                          width: 220,
                          height: 220,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 80),
                        )
                      : const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                ),

                const SizedBox(height: 12),

                // Estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (estado == 'pendiente')
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (estado == 'pendiente') const SizedBox(width: 8),
                    Icon(
                      estado == 'completado'
                          ? Icons.check_circle
                          : (estado == 'expirado'
                              ? Icons.timer_off
                              : Icons.info_outline),
                      color: estado == 'completado'
                          ? Colors.green
                          : (estado == 'expirado'
                              ? Colors.orange
                              : Colors.blueGrey),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      estado == 'completado'
                          ? 'Pago completado'
                          : (estado == 'expirado'
                              ? 'QR expirado'
                              : 'Esperando pago...'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: estado == 'completado'
                            ? Colors.green
                            : (estado == 'expirado'
                                ? Colors.orange
                                : Colors.black87),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.cancelarRecargaQr();
                          Navigator.pop(context);
                        },
                        child: const Text('Cerrar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (estado == 'completado')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            provider.cancelarRecargaQr();
                            Navigator.pop(context);
                            _snack('¡Recarga exitosa!', error: false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Listo'),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: error ? Colors.red : Colors.green),
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
              // Tarjeta de saldo
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
                            const Text('Mi Billetera',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                            Consumer<BilleteraProvider>(
                              builder: (_, p, __) => IconButton(
                                onPressed: p.loadingSaldo ? null : _cargarSaldo,
                                icon: p.loadingSaldo
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.refresh,
                                        color: Colors.white),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 12),
                      Consumer<BilleteraProvider>(
                        builder: (_, p, __) => Text(
                          p.loadingSaldo
                              ? 'Cargando...'
                              : '${p.saldo?.saldo ?? '0.00'} ${p.saldo?.moneda ?? 'BOB'}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Saldo disponible',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón recarga con QR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadingBoton ? null : _pedirMontoYMostrarQr,
                  icon: _loadingBoton
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.qr_code_2),
                  label:
                      Text(_loadingBoton ? 'Procesando...' : 'Recargar con QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF197B9C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info billetera
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer<BilleteraProvider>(
                    builder: (_, p, __) {
                      if (p.saldo == null) {
                        return const Center(
                            child: Text('Cargando información...',
                                style: TextStyle(color: Colors.grey)));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Información de la billetera',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildInfoRow('ID de Billetera',
                              p.saldo!.billeteraId.toString(), Icons.wallet),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                              'Moneda', p.saldo!.moneda, Icons.monetization_on),
                          const SizedBox(height: 12),
                          _buildInfoRow('Estado', 'Activa', Icons.check_circle,
                              valueColor: Colors.green),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Instrucciones
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.info_outline, color: Color(0xFF197B9C)),
                        SizedBox(width: 8),
                        Text('Cómo recargar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ]),
                      SizedBox(height: 12),
                      Text(
                        '1. Presiona "Recargar con QR"\n'
                        '2. Ingresa el monto y genera el QR\n'
                        '3. Paga desde tu app bancaria\n'
                        '4. La app verificará el pago y actualizará tu saldo',
                        style: TextStyle(color: Colors.grey, height: 1.5),
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

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF197B9C)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ),
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor ?? Colors.black),
        ),
      ],
    );
  }
}

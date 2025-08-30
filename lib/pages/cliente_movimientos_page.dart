import 'package:flutter/material.dart';
import '../models/movimiento.dart';
import '../services/billetera_service.dart';

class ClienteMovimientosPage extends StatefulWidget {
  const ClienteMovimientosPage({super.key});

  @override
  State<ClienteMovimientosPage> createState() => _ClienteMovimientosPageState();
}

class _ClienteMovimientosPageState extends State<ClienteMovimientosPage> {
  final BilleteraService _billeteraService = BilleteraService();

  List<Movimiento> _movimientos = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _cargarMovimientos();
  }

  Future<void> _cargarMovimientos() async {
    setState(() => _loading = true);

    try {
      final clienteId = await _billeteraService.getClienteIdFromToken();
      if (clienteId != null) {
        // Por ahora usamos datos de ejemplo ya que el endpoint no está disponible
        _movimientos = _generarMovimientosEjemplo();
      }
    } catch (e) {
      print('Error cargando movimientos: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Movimiento> _generarMovimientosEjemplo() {
    // Datos de ejemplo para mostrar la estructura
    return [
      Movimiento(
        id: 1,
        billeteraId: 1,
        tipo: 'CARGA',
        monto: 50.0,
        concepto: 'Recarga mediante código QR',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Movimiento(
        id: 2,
        billeteraId: 1,
        tipo: 'PAGO',
        monto: -15.0,
        concepto: 'Pago de viaje - Centro a Zona Sur',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Movimiento(
        id: 3,
        billeteraId: 1,
        tipo: 'CARGA',
        monto: 100.0,
        concepto: 'Recarga mediante código QR',
        fecha: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Movimiento(
        id: 4,
        billeteraId: 1,
        tipo: 'PAGO',
        monto: -12.5,
        concepto: 'Pago de viaje - Plaza Murillo a El Alto',
        fecha: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cargarMovimientos,
        color: const Color(0xFF197B9C),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF197B9C),
                ),
              )
            : _movimientos.isEmpty
                ? _buildEmptyState()
                : _buildMovimientosList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Sin movimientos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Aquí aparecerán tus recargas, pagos de viajes y otros movimientos de tu billetera.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _cargarMovimientos,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF197B9C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovimientosList() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                    'Resumen de movimientos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_movimientos.length} transacciones',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Últimos 30 días',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Lista de movimientos
          const Text(
            'Historial de transacciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _movimientos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final movimiento = _movimientos[index];
              return _buildMovimientoCard(movimiento);
            },
          ),

          const SizedBox(height: 20),

          // Nota informativa
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Los movimientos se muestran en tiempo real. Desliza hacia abajo para actualizar.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientoCard(Movimiento movimiento) {
    final esPositivo = movimiento.monto >= 0;
    final color = esPositivo ? Colors.green : Colors.red;
    final icono = esPositivo ? Icons.add_circle : Icons.remove_circle;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            icono,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          movimiento.tipoDisplayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movimiento.concepto != null) ...[
              const SizedBox(height: 4),
              Text(
                movimiento.concepto!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatearFecha(movimiento.fecha),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Text(
          movimiento.montoFormateado,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diferencia.inDays == 1) {
      return 'Ayer ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diferencia.inDays < 7) {
      final diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return '${diasSemana[fecha.weekday - 1]} ${fecha.day}/${fecha.month}';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}

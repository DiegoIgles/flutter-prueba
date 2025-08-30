import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movimiento.dart';
import '../providers/chofer_billetera_provider.dart';

class ChoferMovimientosPage extends StatefulWidget {
  const ChoferMovimientosPage({super.key});

  @override
  State<ChoferMovimientosPage> createState() => _ChoferMovimientosPageState();
}

class _ChoferMovimientosPageState extends State<ChoferMovimientosPage> {
  @override
  void initState() {
    super.initState();
    // Cargar movimientos usando el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ChoferBilleteraProvider>(context, listen: false);
      if (provider.movimientos.isEmpty && !provider.loadingMovimientos) {
        provider.cargarMovimientos();
      }
    });
  }

  Future<void> _cargarMovimientos() async {
    await Provider.of<ChoferBilleteraProvider>(context, listen: false)
        .cargarMovimientos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cargarMovimientos,
        color: const Color(0xFF197B9C),
        child: Consumer<ChoferBilleteraProvider>(
          builder: (context, provider, child) {
            if (provider.loadingMovimientos) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF197B9C),
                ),
              );
            }

            if (provider.errorMovimientos != null) {
              return _buildErrorState(provider.errorMovimientos!);
            }

            if (provider.movimientos.isEmpty) {
              return _buildEmptyState();
            }

            return _buildMovimientosList(provider.movimientos);
          },
        ),
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
                'Aquí aparecerán tus ganancias por viajes, retiros y otros movimientos de tu billetera.',
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

  Widget _buildMovimientosList(List<Movimiento> movimientos) {
    // Calcular estadísticas
    final totalGanancias = movimientos
        .where((m) => m.monto > 0)
        .fold(0.0, (sum, m) => sum + m.monto);

    final totalRetiros = movimientos
        .where((m) => m.monto < 0)
        .fold(0.0, (sum, m) => sum + m.monto.abs());

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de resumen con estadísticas
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
                    '${movimientos.length} transacciones',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEstadistica(
                          'Ganancias',
                          '+${totalGanancias.toStringAsFixed(2)} BOB',
                          Icons.trending_up,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEstadistica(
                          'Retiros',
                          '-${totalRetiros.toStringAsFixed(2)} BOB',
                          Icons.trending_down,
                          Colors.orange,
                        ),
                      ),
                    ],
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
            itemCount: movimientos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final movimiento = movimientos[index];
              return _buildMovimientoCard(movimiento);
            },
          ),

          const SizedBox(height: 20),

          // Nota informativa para choferes
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
                        'Información para choferes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Las ganancias por viajes se registran automáticamente\n'
                    '• Puedes retirar tu saldo cuando desees\n'
                    '• Los movimientos se actualizan en tiempo real\n'
                    '• Mantén actualizada tu información de retiro',
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
    );
  }

  Widget _buildEstadistica(
      String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Error al cargar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _cargarMovimientos,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
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

  Widget _buildMovimientoCard(Movimiento movimiento) {
    final esPositivo = movimiento.monto >= 0;
    final color = esPositivo ? Colors.green : Colors.red;
    final icono = esPositivo ? Icons.add_circle : Icons.remove_circle;

    // Determinar tipo específico para chofer
    String tipoEspecifico = movimiento.tipoDisplayName;
    IconData iconoEspecifico = icono;

    if (esPositivo) {
      if (movimiento.tipo == 'GANANCIA' ||
          movimiento.concepto?.contains('viaje') == true) {
        tipoEspecifico = 'Ganancia por viaje';
        iconoEspecifico = Icons.directions_bus;
      } else if (movimiento.tipo == 'RECARGA') {
        tipoEspecifico = 'Ingreso';
        iconoEspecifico = Icons.account_balance_wallet;
      }
    } else {
      if (movimiento.tipo == 'RETIRO') {
        tipoEspecifico = 'Retiro';
        iconoEspecifico = Icons.money_off;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            iconoEspecifico,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          tipoEspecifico,
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

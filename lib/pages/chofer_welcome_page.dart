import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../services/vehiculo_service.dart';

class ChoferWelcomePage extends StatefulWidget {
  final String token;
  const ChoferWelcomePage({super.key, required this.token});

  @override
  State<ChoferWelcomePage> createState() => _ChoferWelcomePageState();
}

class _ChoferWelcomePageState extends State<ChoferWelcomePage> {
  final _vehiculoService = VehiculoService();
  late Future<List<Vehiculo>> _future;

  @override
  void initState() {
    super.initState();
    _future = _vehiculoService.listarMisVehiculos();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _vehiculoService.listarMisVehiculos();
    });
    await _future; // asegura que termine antes de soltar el refresh
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return const Color(0xFF2E7D32); // verde
      case 'inactivo':
        return const Color(0xFF9E9E9E); // gris
      case 'mantenimiento':
        return const Color(0xFFF9A825); // ámbar
      default:
        return const Color(0xFF1976D2); // azul
    }
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _vehiculoCard(Vehiculo v) {
    final estadoColor = _estadoColor(v.estado);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Aquí luego puedes navegar a "Detalle de vehículo"
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono grande
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.directions_bus, size: 30, color: estadoColor),
              ),
              const SizedBox(width: 14),

              // Texto principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Placa y estado
                    Row(
                      children: [
                        Text(
                          v.placa,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: estadoColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: estadoColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            v.estado.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: estadoColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Marca y modelo
                    Text(
                      '${v.marca} • ${v.modelo}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Chips: año y capacidad
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('Año ${v.anio}', Icons.event),
                        _chip('Cap. ${v.capacidad}', Icons.airline_seat_recline_normal),
                        _chip('Tipo #${v.tipoId}', Icons.category),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const topColor = Color(0xFF0B0530);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: topColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Panel Chofer', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Vehiculo>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                title: Center(child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(),
                )),
              );
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Ocurrió un error al cargar tus vehículos:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ),
                ],
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 60),
                  Icon(Icons.directions_bus_filled, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'No tienes vehículos asignados.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Cuando te asignen vehículos, aparecerán aquí.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: items.length,
              itemBuilder: (_, i) => _vehiculoCard(items[i]),
            );
          },
        ),
      ),
    );
  }
}

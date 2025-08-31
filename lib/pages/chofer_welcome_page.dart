import 'package:flutter/material.dart';
import 'package:prueba/models/tipo_vehiculo.dart';
import 'package:prueba/services/auth_service.dart';
import 'package:prueba/services/viaje_service.dart';
import '../models/vehiculo.dart';
import '../services/vehiculo_service.dart';
import 'package:prueba/widgets/sidebartChofer.dart'; // Asegúrate que esta ruta esté correcta
import 'package:prueba/pages/ViajeDetallePage.dart';

class ChoferWelcomePage extends StatefulWidget {
  final String token;
  const ChoferWelcomePage({super.key, required this.token});

  @override
  State<ChoferWelcomePage> createState() => _ChoferWelcomePageState();
}

Map<int, String> _tipoNombre = {};
bool _cargandoTipos = true;

class _ChoferWelcomePageState extends State<ChoferWelcomePage> {
  final _vehiculoService = VehiculoService();
  final _auth = AuthService();
  final _viajeService = ViajeService(); // NUEVO

  int? _viajeIdActual; // NUEVO
  int? _vehiculoEnViaje; // NUEVO (para marcar card activa)
  String? _montoActual; // opcional, mostrado al iniciar
  bool _accionando = false; // evita taps múltiples
  late Future<List<Vehiculo>> _future;

  @override
  void initState() {
    super.initState();
    _future = _vehiculoService.listarMisVehiculos();
    _cargarTipos();
  }

  Future<void> _cargarTipos() async {
    try {
      final tipos = await _vehiculoService.listarTipos();
      setState(() {
        _tipoNombre = {for (final t in tipos) t.id: t.nombre};
        _cargandoTipos = false;
      });
    } catch (e) {
      setState(() => _cargandoTipos = false);
      // (opcional) Mostrar un snackbar si quieres avisar
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudieron cargar tipos: $e')));
    }
  }

  Future<void> _reload() async {
    setState(() {
      _future = _vehiculoService.listarMisVehiculos();
    });
    await _future; // asegura que termine antes de soltar el refresh
  }

  Future<void> _iniciarViaje(int vehiculoId) async {
    if (_accionando) return;
    setState(() => _accionando = true);
    try {
      final r = await _viajeService.start(vehiculoId);
      setState(() {
        _viajeIdActual = r.viajeId;
        _vehiculoEnViaje = vehiculoId;
        _montoActual = r.monto;
      });
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViajeDetallePage(
            viajeId: r.viajeId,
            monto: r.monto,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar viaje: $e')),
      );
    } finally {
      if (mounted) setState(() => _accionando = false);
    }
  }

  Future<void> _finalizarViaje() async {
    if (_accionando || _viajeIdActual == null) return;
    setState(() => _accionando = true);
    try {
      final r = await _viajeService.finish(_viajeIdActual!);
      setState(() {
        _viajeIdActual = null;
        _vehiculoEnViaje = null;
        _montoActual = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🏁 Viaje finalizado — Estado: ${r.estado}')),
      );
      await _reload(); // refresca por si cambia algo server-side
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo finalizar viaje: $e')),
      );
    } finally {
      if (mounted) setState(() => _accionando = false);
    }
  }

  Future<void> _openCrearVehiculo() async {
    // 1) Traer tipos
    late List<TipoVehiculo> tipos;
    try {
      tipos = await _vehiculoService.listarTipos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar tipos: $e')),
      );
      return;
    }
    if (!mounted) return;

    // 2) Controllers y estado local del form
    final placaCtrl = TextEditingController();
    final marcaCtrl = TextEditingController();
    final modeloCtrl = TextEditingController();
    final anioCtrl =
        TextEditingController(text: DateTime.now().year.toString());
    final capacidadCtrl = TextEditingController(text: '1');

    String estado = 'activo';
    TipoVehiculo? tipoSel = tipos.isNotEmpty ? tipos.first : null;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text('Nuevo vehículo',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: placaCtrl,
                        decoration: const InputDecoration(labelText: 'Placa'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingrese la placa'
                            : null,
                      ),
                      TextFormField(
                        controller: marcaCtrl,
                        decoration: const InputDecoration(labelText: 'Marca'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingrese la marca'
                            : null,
                      ),
                      TextFormField(
                        controller: modeloCtrl,
                        decoration: const InputDecoration(labelText: 'Modelo'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingrese el modelo'
                            : null,
                      ),
                      TextFormField(
                        controller: anioCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Año'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingrese el año';
                          final n = int.tryParse(v);
                          if (n == null ||
                              n < 1900 ||
                              n > DateTime.now().year + 1) {
                            return 'Año inválido';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: capacidadCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Capacidad'),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Ingrese la capacidad';
                          final n = int.tryParse(v);
                          if (n == null || n <= 0) return 'Capacidad inválida';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: estado,
                        decoration: const InputDecoration(labelText: 'Estado'),
                        items: const [
                          DropdownMenuItem(
                              value: 'activo', child: Text('Activo')),
                          DropdownMenuItem(
                              value: 'inactivo', child: Text('Inactivo')),
                          DropdownMenuItem(
                              value: 'mantenimiento',
                              child: Text('Mantenimiento')),
                        ],
                        onChanged: (val) =>
                            setSheet(() => estado = val ?? 'activo'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TipoVehiculo>(
                        value: tipoSel,
                        decoration: const InputDecoration(
                            labelText: 'Tipo de vehículo'),
                        items: tipos
                            .map((t) => DropdownMenuItem(
                                value: t, child: Text(t.nombre)))
                            .toList(),
                        onChanged: (val) => setSheet(() => tipoSel = val),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar'),
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            if (tipoSel == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Seleccione un tipo de vehículo')),
                              );
                              return;
                            }

                            // 3) Obtener chofer_id desde el token guardado
                            final choferId = await _auth.getChoferIdFromToken();
                            if (choferId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No se pudo obtener tu ID de chofer. Inicia sesión nuevamente.')),
                              );
                              return;
                            }

                            try {
                              await _vehiculoService.crearVehiculo(
                                placa: placaCtrl.text.trim(),
                                marca: marcaCtrl.text.trim(),
                                modelo: modeloCtrl.text.trim(),
                                anio: int.parse(anioCtrl.text.trim()),
                                capacidad: int.parse(capacidadCtrl.text.trim()),
                                estado: estado,
                                tipoId: tipoSel!.id,
                                choferId: choferId,
                              );
                              if (!mounted) return;
                              Navigator.pop(context); // cerrar modal
                              await _reload(); // refrescar el listado
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Vehículo creado correctamente')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error al crear vehículo: $e')),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: estadoColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: estadoColor.withOpacity(0.5)),
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
                        _chip('Cap. ${v.capacidad}',
                            Icons.airline_seat_recline_normal),
                        _chip(
                          _cargandoTipos
                              ? 'Tipo…'
                              : (_tipoNombre[v.tipoId] ?? 'Tipo ${v.tipoId}'),
                          Icons.category,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _accionando
                              ? null
                              : (_vehiculoEnViaje == v.id
                                  ? _finalizarViaje
                                  : () => _iniciarViaje(v.id)),
                          icon: Icon(_vehiculoEnViaje == v.id
                              ? Icons.stop
                              : Icons.play_arrow),
                          label: Text(
                              _vehiculoEnViaje == v.id
                                  ? 'Finalizar'
                                  : 'Iniciar',
                              style: const TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _vehiculoEnViaje == v.id
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_vehiculoEnViaje == v.id && _montoActual != null)
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Monto: $_montoActual',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
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

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0530), Color(0xFF197B9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Icono del drawer
              Builder(
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu),
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Título y descripción
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Panel Chofer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gestiona tus vehículos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Indicador de estado si hay viaje activo
          if (_viajeIdActual != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'En viaje',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const AppSidebarChofer(),
      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: FutureBuilder<List<Vehiculo>>(
                future: _future,
                builder: (context, snapshot) {
                  // ... TU MISMO BUILDER SIN CAMBIOS ...
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Center(
                          child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: CircularProgressIndicator(),
                      )),
                    );
                  }
                  if (snapshot.hasError) {
                    return ListView(
                      children: [
                        const SizedBox(height: 40),
                        Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
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
                        Icon(Icons.directions_bus_filled,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'No tienes vehículos asignados.',
                            style:
                                TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCrearVehiculo,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo vehículo'),
      ),
    );
  }
}

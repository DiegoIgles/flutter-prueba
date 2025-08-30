import 'package:flutter/material.dart';
import 'package:prueba/models/tipo_vehiculo.dart';
import 'package:prueba/services/auth_service.dart';
import 'package:prueba/services/viaje_service.dart';
import '../models/vehiculo.dart';
import '../services/vehiculo_service.dart';

class ChoferMisVehiculosPage extends StatefulWidget {
  final String token;
  const ChoferMisVehiculosPage({super.key, required this.token});

  @override
  State<ChoferMisVehiculosPage> createState() => _ChoferMisVehiculosPageState();
}

class _ChoferMisVehiculosPageState extends State<ChoferMisVehiculosPage> {
  final _vehiculoService = VehiculoService();
  final _auth = AuthService();
  final _viajeService = ViajeService();

  int? _viajeIdActual;
  int? _vehiculoEnViaje;
  String? _montoActual;
  bool _accionando = false;
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
    await _future;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('🚀 Viaje iniciado (ID ${r.viajeId}) — Monto: ${r.monto}'),
          backgroundColor: const Color(0xFF197B9C),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo iniciar viaje: $e'),
          backgroundColor: Colors.red,
        ),
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
        SnackBar(
          content: Text('🏁 Viaje finalizado — Estado: ${r.estado}'),
          backgroundColor: Colors.green,
        ),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo finalizar viaje: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _accionando = false);
    }
  }

  Future<void> _openCrearVehiculo() async {
    late List<TipoVehiculo> tipos;
    try {
      tipos = await _vehiculoService.listarTipos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cargar tipos: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!mounted) return;

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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
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
                              Icons.directions_bus,
                              color: Color(0xFF197B9C),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Nuevo vehículo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B0530),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(placaCtrl, 'Placa', Icons.badge),
                      const SizedBox(height: 16),
                      _buildTextField(marcaCtrl, 'Marca', Icons.business),
                      const SizedBox(height: 16),
                      _buildTextField(modeloCtrl, 'Modelo', Icons.category),
                      const SizedBox(height: 16),
                      _buildTextField(anioCtrl, 'Año', Icons.calendar_today,
                          isNumber: true),
                      const SizedBox(height: 16),
                      _buildTextField(capacidadCtrl, 'Capacidad', Icons.people,
                          isNumber: true),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: estado,
                        label: 'Estado',
                        icon: Icons.info,
                        items: const [
                          {'value': 'activo', 'text': 'Activo'},
                          {'value': 'inactivo', 'text': 'Inactivo'},
                          {'value': 'mantenimiento', 'text': 'Mantenimiento'},
                        ],
                        onChanged: (val) =>
                            setSheet(() => estado = val ?? 'activo'),
                      ),
                      const SizedBox(height: 16),
                      _buildTipoDropdown(tipos, tipoSel,
                          (val) => setSheet(() => tipoSel = val)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar Vehículo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF197B9C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () => _guardarVehiculo(
                              formKey,
                              tipoSel,
                              placaCtrl,
                              marcaCtrl,
                              modeloCtrl,
                              anioCtrl,
                              capacidadCtrl,
                              estado),
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

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF197B9C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF197B9C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF197B9C), width: 2),
        ),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese $label' : null,
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF197B9C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF197B9C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF197B9C), width: 2),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item['value'],
                child: Text(item['text']!),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTipoDropdown(List<TipoVehiculo> tipos, TipoVehiculo? value,
      Function(TipoVehiculo?) onChanged) {
    return DropdownButtonFormField<TipoVehiculo>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Tipo de vehículo',
        prefixIcon: const Icon(Icons.directions_bus, color: Color(0xFF197B9C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF197B9C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF197B9C), width: 2),
        ),
      ),
      items: tipos
          .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.nombre),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _guardarVehiculo(
    GlobalKey<FormState> formKey,
    TipoVehiculo? tipoSel,
    TextEditingController placaCtrl,
    TextEditingController marcaCtrl,
    TextEditingController modeloCtrl,
    TextEditingController anioCtrl,
    TextEditingController capacidadCtrl,
    String estado,
  ) async {
    if (!formKey.currentState!.validate()) return;
    if (tipoSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un tipo de vehículo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final choferId = await _auth.getChoferIdFromToken();
    if (choferId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No se pudo obtener tu ID de chofer. Inicia sesión nuevamente.'),
          backgroundColor: Colors.red,
        ),
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
        tipoId: tipoSel.id,
        choferId: choferId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Vehículo creado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear vehículo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return const Color(0xFF197B9C);
      case 'inactivo':
        return const Color(0xFF9E9E9E);
      case 'mantenimiento':
        return const Color(0xFFF9A825);
      default:
        return const Color(0xFF0B0530);
    }
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF197B9C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF197B9C).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF197B9C)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B0530),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehiculoCard(Vehiculo v) {
    final estadoColor = _estadoColor(v.estado);
    final isEnViaje = _vehiculoEnViaje == v.id;

    return Card(
      elevation: isEnViaje ? 8 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isEnViaje
              ? const LinearGradient(
                  colors: [Color(0xFF197B9C), Color(0xFF0B0530)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnViaje ? null : Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isEnViaje
                            ? Colors.white.withOpacity(0.2)
                            : estadoColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_bus,
                        size: 30,
                        color: isEnViaje ? Colors.white : estadoColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                v.placa,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: isEnViaje
                                      ? Colors.white
                                      : const Color(0xFF0B0530),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isEnViaje
                                      ? Colors.white.withOpacity(0.2)
                                      : estadoColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: isEnViaje
                                          ? Colors.white.withOpacity(0.5)
                                          : estadoColor.withOpacity(0.5)),
                                ),
                                child: Text(
                                  v.estado.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isEnViaje ? Colors.white : estadoColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${v.marca} • ${v.modelo}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isEnViaje
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Año ${v.anio}', Icons.event, isEnViaje),
                    _buildChip('Cap. ${v.capacidad}',
                        Icons.airline_seat_recline_normal, isEnViaje),
                    _buildChip('Tipo #${v.tipoId}', Icons.category, isEnViaje),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: isEnViaje
                          ? ElevatedButton.icon(
                              onPressed: _accionando ? null : _finalizarViaje,
                              icon: const Icon(Icons.stop, size: 20),
                              label: const Text('Finalizar Viaje'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: _accionando
                                  ? null
                                  : () => _iniciarViaje(v.id),
                              icon: const Icon(Icons.play_arrow, size: 20),
                              label: const Text('Iniciar Viaje'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF197B9C),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                    ),
                    if (isEnViaje && _montoActual != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Monto: $_montoActual',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, bool isEnViaje) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isEnViaje
            ? Colors.white.withOpacity(0.2)
            : const Color(0xFF197B9C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnViaje
              ? Colors.white.withOpacity(0.3)
              : const Color(0xFF197B9C).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isEnViaje ? Colors.white : const Color(0xFF197B9C),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isEnViaje ? Colors.white : const Color(0xFF0B0530),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _reload,
        color: const Color(0xFF197B9C),
        child: FutureBuilder<List<Vehiculo>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF197B9C),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: items.length,
              itemBuilder: (_, i) => _vehiculoCard(items[i]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCrearVehiculo,
        backgroundColor: const Color(0xFF197B9C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Vehículo'),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
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
              const Text(
                'Ocurrió un error al cargar tus vehículos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF197B9C),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
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
            children: [
              Icon(
                Icons.directions_bus_filled,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Sin vehículos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No tienes vehículos asignados.\nCrea tu primer vehículo para comenzar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _openCrearVehiculo,
                icon: const Icon(Icons.add),
                label: const Text('Crear Vehículo'),
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
}

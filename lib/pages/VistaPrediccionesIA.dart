import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrediccionesIAPage extends StatefulWidget {
  final String token;

  const PrediccionesIAPage({super.key, required this.token});

  @override
  State<PrediccionesIAPage> createState() => _PrediccionesIAPageState();
}

class _PrediccionesIAPageState extends State<PrediccionesIAPage> {
  List<dynamic> predicciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPredicciones();
  }

  Future<void> _cargarPredicciones() async {
    setState(() => cargando = true);
    final url = Uri.parse('http://127.0.0.1:8000/api/predicciones/actuales');
    final resp = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      setState(() {
        predicciones = data['predicciones'];
        cargando = false;
      });
    } else {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar predicciones: ${resp.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _diaSemana(int dia) {
    const dias = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    return dias[dia % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 Predicciones IA'),
        backgroundColor: const Color(0xFF0B0530),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarPredicciones,
        color: const Color(0xFF197B9C),
        child: cargando
            ? const Center(child: CircularProgressIndicator())
            : predicciones.isEmpty
                ? const Center(child: Text('No se encontraron predicciones'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: predicciones.length,
                    itemBuilder: (context, index) {
                      final p = predicciones[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.directions_bus, size: 30),
                          title: Text('Vehículo #${p['vehiculo_id']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Día: ${_diaSemana(p['dia_semana_actual'])}, Hora: ${p['hora_actual'].toString().padLeft(2, '0')}:00'),
                              Text(
                                  '🎟️ Tickets estimados: ${p['tickets_estimados']}'),
                              Text(
                                  '💰 Monto estimado: Bs ${p['monto_estimado']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

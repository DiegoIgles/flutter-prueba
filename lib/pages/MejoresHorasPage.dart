import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MejoresHorasPage extends StatefulWidget {
  final String token;

  const MejoresHorasPage({super.key, required this.token});

  @override
  State<MejoresHorasPage> createState() => _MejoresHorasPageState();
}

class _MejoresHorasPageState extends State<MejoresHorasPage> {
  late Future<Map<String, List<Map<String, dynamic>>>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchMejoresHoras();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchMejoresHoras() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/predicciones/mejores-horas');
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener las mejores horas');
    }

    final json = jsonDecode(response.body);
    final Map<String, dynamic> data = json["mejores_horas"];

    // Convertimos a Map<String, List<Map<String, dynamic>>>
    return data.map((vehiculoId, horas) {
      final lista = List<Map<String, dynamic>>.from(horas);
      return MapEntry(vehiculoId, lista);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mejores Horas del Día"),
        backgroundColor: const Color(0xFF0B0530),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0B0530)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text("No se encontraron mejores horas."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: data.entries.map((entry) {
              final vehiculoId = entry.key;
              final horas = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: const Color(0xFFEAF6FF),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🚐 Vehículo ID: $vehiculoId",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ...horas.map((h) {
                        return ListTile(
                          leading: const Icon(Icons.access_time, color: Color(0xFF0B0530)),
                          title: Text("Hora: ${h["hora"]}:00"),
                          subtitle: Text(
                              "Tickets estimados: ${h["tickets_estimados"]}\nMonto estimado: Bs ${h["monto_estimado"]}"),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

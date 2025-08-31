import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movipay/models/tipo_vehiculo.dart';
import '../models/vehiculo.dart';
import 'auth_service.dart';

class VehiculoService {
  final _auth = AuthService();

  Future<List<Vehiculo>> listarMisVehiculos(
      {int limit = 50, int offset = 0}) async {
    final headers = await _auth.authHeaders(chofer: true);
    final uri = Uri.parse(
        '${AuthService.baseUrl}/choferes/me/vehiculos?limit=$limit&offset=$offset');

    final res = await http.get(uri, headers: headers);

    // Manejo de sesión expirada/no autorizada
    if (res.statusCode == 401) {
      throw Exception('No autorizado. Inicia sesión nuevamente.');
    }

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => Vehiculo.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<List<TipoVehiculo>> listarTipos() async {
    final uri = Uri.parse('${AuthService.baseUrl}/tipo_vehiculos');
    // (si este endpoint requiere auth, agrega headers con token chofer)
    final headers = await _auth.authHeaders(chofer: true);

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200)
      throw Exception('Error ${res.statusCode}: ${res.body}');

    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => TipoVehiculo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Vehiculo> crearVehiculo({
    required String placa,
    required String marca,
    required String modelo,
    required int anio,
    required int capacidad,
    required String
        estado, // 'activo' | 'inactivo' | 'mantenimiento' (según tu backend)
    required int tipoId,
    required int choferId,
  }) async {
    final headers = await _auth.authHeaders(chofer: true);
    final uri = Uri.parse('${AuthService.baseUrl}/vehiculos');

    final body = jsonEncode({
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'capacidad': capacidad,
      'estado': estado,
      'tipo_id': tipoId,
      'chofer_id': choferId,
    });

    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode != 201)
      throw Exception('Error ${res.statusCode}: ${res.body}');

    return Vehiculo.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehiculo.dart';
import 'auth_service.dart';

class VehiculoService {
  final _auth = AuthService();

  Future<List<Vehiculo>> listarMisVehiculos({int limit = 50, int offset = 0}) async {
    final headers = await _auth.authHeaders(chofer: true);
    final uri = Uri.parse('${AuthService.baseUrl}/choferes/me/vehiculos?limit=$limit&offset=$offset');

    final res = await http.get(uri, headers: headers);

    // Manejo de sesión expirada/no autorizada
    if (res.statusCode == 401) {
      throw Exception('No autorizado. Inicia sesión nuevamente.');
    }

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => Vehiculo.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
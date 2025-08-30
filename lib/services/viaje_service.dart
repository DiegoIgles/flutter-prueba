import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/viaje.dart';
import 'auth_service.dart';

class ViajeService {
  final _auth = AuthService();

  Future<ViajeStartResponse> start(int vehiculoId) async {
    final headers = await _auth.authHeaders(chofer: true);
    final uri = Uri.parse('${AuthService.baseUrl}/viajes/start');
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(ViajeStartRequest(vehiculoId: vehiculoId).toJson()),
    );
    if (res.statusCode != 201) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    return ViajeStartResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<ViajeFinishResponse> finish(int viajeId) async {
    final headers = await _auth.authHeaders(chofer: true);
    final uri = Uri.parse('${AuthService.baseUrl}/viajes/finish');
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(ViajeFinishRequest(viajeId: viajeId).toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    return ViajeFinishResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

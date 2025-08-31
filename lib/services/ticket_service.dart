import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketService {
  static const String _baseUrl = 'http://11.0.1.176:8000/api';

  static Future<Map<String, dynamic>> pagarTicket({
    required int ticketOfferId,
    required int clienteId,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/tickets/accept');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ticket_offer_id': ticketOfferId,
        'cliente_id': clienteId,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al pagar ticket: \\n${response.body}');
    }
  }
}

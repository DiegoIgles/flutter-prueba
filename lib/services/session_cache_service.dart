import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cliente.dart';

class SessionCacheService {
  static const String _keyClienteToken = 'cliente_token';
  static const String _keyChoferToken = 'chofer_token';
  static const String _keyClienteData = 'cliente_data';
  static const String _keyChoferData = 'chofer_data';
  static const String _keyUserType = 'user_type'; // 'cliente' o 'chofer'

  // Guardar sesión de cliente
  static Future<void> saveClienteSession({
    required String token,
    required Cliente cliente,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyClienteToken, token);
    await prefs.setString(_keyClienteData, jsonEncode(cliente.toJson()));
    await prefs.setString(_keyUserType, 'cliente');
    
    print('✅ Sesión de cliente guardada en caché');
  }

  // Guardar sesión de chofer
  static Future<void> saveChoferSession({
    required String token,
    Map<String, dynamic>? choferData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyChoferToken, token);
    if (choferData != null) {
      await prefs.setString(_keyChoferData, jsonEncode(choferData));
    }
    await prefs.setString(_keyUserType, 'chofer');
    
    print('✅ Sesión de chofer guardada en caché');
  }

  // Obtener token de cliente
  static Future<String?> getClienteToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyClienteToken);
  }

  // Obtener token de chofer
  static Future<String?> getChoferToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyChoferToken);
  }

  // Obtener datos de cliente
  static Future<Cliente?> getClienteData() async {
    final prefs = await SharedPreferences.getInstance();
    final clienteJson = prefs.getString(_keyClienteData);
    
    if (clienteJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(clienteJson);
        return Cliente.fromJson(data);
      } catch (e) {
        print('❌ Error decodificando datos de cliente: $e');
        return null;
      }
    }
    return null;
  }

  // Obtener datos de chofer
  static Future<Map<String, dynamic>?> getChoferData() async {
    final prefs = await SharedPreferences.getInstance();
    final choferJson = prefs.getString(_keyChoferData);
    
    if (choferJson != null) {
      try {
        return jsonDecode(choferJson) as Map<String, dynamic>;
      } catch (e) {
        print('❌ Error decodificando datos de chofer: $e');
        return null;
      }
    }
    return null;
  }

  // Obtener tipo de usuario de la sesión actual
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserType);
  }

  // Verificar si hay sesión activa
  static Future<bool> hasActiveSession() async {
    final userType = await getUserType();
    
    if (userType == 'cliente') {
      final token = await getClienteToken();
      return token != null && token.isNotEmpty;
    } else if (userType == 'chofer') {
      final token = await getChoferToken();
      return token != null && token.isNotEmpty;
    }
    
    return false;
  }

  // Obtener información completa de la sesión
  static Future<Map<String, dynamic>?> getActiveSession() async {
    final userType = await getUserType();
    
    if (userType == 'cliente') {
      final token = await getClienteToken();
      final cliente = await getClienteData();
      
      if (token != null && cliente != null) {
        return {
          'type': 'cliente',
          'token': token,
          'user': cliente,
        };
      }
    } else if (userType == 'chofer') {
      final token = await getChoferToken();
      final choferData = await getChoferData();
      
      if (token != null) {
        return {
          'type': 'chofer',
          'token': token,
          'user': choferData,
        };
      }
    }
    
    return null;
  }

  // Limpiar sesión de cliente
  static Future<void> clearClienteSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_keyClienteToken);
    await prefs.remove(_keyClienteData);
    
    // Solo limpiar user_type si era cliente
    final userType = await getUserType();
    if (userType == 'cliente') {
      await prefs.remove(_keyUserType);
    }
    
    print('🧹 Sesión de cliente limpiada');
  }

  // Limpiar sesión de chofer
  static Future<void> clearChoferSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_keyChoferToken);
    await prefs.remove(_keyChoferData);
    
    // Solo limpiar user_type si era chofer
    final userType = await getUserType();
    if (userType == 'chofer') {
      await prefs.remove(_keyUserType);
    }
    
    print('🧹 Sesión de chofer limpiada');
  }

  // Limpiar todas las sesiones
  static Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_keyClienteToken);
    await prefs.remove(_keyChoferToken);
    await prefs.remove(_keyClienteData);
    await prefs.remove(_keyChoferData);
    await prefs.remove(_keyUserType);
    
    print('🧹 Todas las sesiones limpiadas');
  }
}

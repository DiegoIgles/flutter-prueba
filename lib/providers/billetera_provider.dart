import 'package:flutter/foundation.dart';
import '../services/billetera_service.dart';
import '../models/billetera.dart';

class BilleteraProvider extends ChangeNotifier {
  final BilleteraService _billeteraService = BilleteraService();
  
  BilleteraSaldoResponse? _saldo;
  bool _loadingSaldo = false;
  String? _error;
  
  BilleteraSaldoResponse? get saldo => _saldo;
  bool get loadingSaldo => _loadingSaldo;
  String? get error => _error;
  
  Future<void> cargarSaldo() async {
    if (_loadingSaldo) return; // Evitar múltiples cargas simultáneas
    
    _loadingSaldo = true;
    _error = null;
    notifyListeners();
    
    try {
      final clienteId = await _billeteraService.getClienteIdFromToken();
      if (clienteId != null) {
        final saldo = await _billeteraService.getSaldo(clienteId);
        _saldo = saldo;
        _error = null;
      } else {
        _error = 'No se pudo obtener el ID del cliente';
      }
    } catch (e) {
      _error = 'Error al cargar saldo: $e';
      print('🚨 Error en BilleteraProvider: $e');
    } finally {
      _loadingSaldo = false;
      notifyListeners();
    }
  }
  
  Future<void> cargarCreditos({
    required double monto,
    required String concepto,
  }) async {
    if (_saldo == null) {
      throw Exception('No hay información de billetera disponible');
    }
    
    try {
      final resultado = await _billeteraService.cargarSaldo(
        billeteraId: _saldo!.billeteraId,
        monto: monto,
        concepto: concepto,
      );
      
      // Actualizar el saldo local
      _saldo = BilleteraSaldoResponse(
        ok: true,
        billeteraId: _saldo!.billeteraId,
        saldo: resultado.saldo,
        moneda: _saldo!.moneda,
      );
      
      notifyListeners();
    } catch (e) {
      print('🚨 Error cargando créditos: $e');
      rethrow;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

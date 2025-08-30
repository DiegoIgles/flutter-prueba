import 'package:flutter/foundation.dart';
import '../models/billetera.dart';
import '../models/movimiento.dart';
import '../services/chofer_billetera_service.dart';
import '../services/auth_service.dart';

class ChoferBilleteraProvider with ChangeNotifier {
  final ChoferBilleteraService _billeteraService = ChoferBilleteraService();

  // Estado del saldo
  BilleteraSaldoResponse? _saldo;
  bool _loadingSaldo = false;
  String? _error;

  // Estado de los movimientos
  List<Movimiento> _movimientos = [];
  bool _loadingMovimientos = false;
  String? _errorMovimientos;

  // Getters
  BilleteraSaldoResponse? get saldo => _saldo;
  bool get loadingSaldo => _loadingSaldo;
  String? get error => _error;

  List<Movimiento> get movimientos => _movimientos;
  bool get loadingMovimientos => _loadingMovimientos;
  String? get errorMovimientos => _errorMovimientos;

  // Cargar saldo
  Future<void> cargarSaldo() async {
    _loadingSaldo = true;
    _error = null;
    notifyListeners();

    try {
      final choferId = await AuthService().getChoferIdFromToken();
      if (choferId == null) {
        throw Exception('No se pudo obtener el ID del chofer');
      }

      _saldo = await _billeteraService.getSaldo(choferId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('❌ [ChoferBilleteraProvider] Error cargando saldo: $e');
    } finally {
      _loadingSaldo = false;
      notifyListeners();
    }
  }

  // Cargar movimientos
  Future<void> cargarMovimientos() async {
    _loadingMovimientos = true;
    _errorMovimientos = null;
    notifyListeners();

    try {
      final choferId = await AuthService().getChoferIdFromToken();
      if (choferId == null) {
        throw Exception('No se pudo obtener el ID del chofer');
      }

      _movimientos = await _billeteraService.getMovimientos(choferId);
      _errorMovimientos = null;
    } catch (e) {
      _errorMovimientos = e.toString();
      print('❌ [ChoferBilleteraProvider] Error cargando movimientos: $e');
    } finally {
      _loadingMovimientos = false;
      notifyListeners();
    }
  }

  // Cargar créditos (para administradores o promociones)
  Future<void> cargarCreditos({
    required double monto,
    required String concepto,
  }) async {
    if (_saldo == null) {
      throw Exception('No hay información de billetera disponible');
    }

    try {
      await _billeteraService.cargarCreditos(
        billeteraId: _saldo!.billeteraId,
        monto: monto,
        concepto: concepto,
      );

      // Recargar saldo y movimientos después de la carga
      await cargarSaldo();
      await cargarMovimientos();
    } catch (e) {
      print('❌ [ChoferBilleteraProvider] Error cargando créditos: $e');
      rethrow;
    }
  }

  // Retirar saldo
  Future<void> retirarSaldo({
    required double monto,
    required String concepto,
  }) async {
    if (_saldo == null) {
      throw Exception('No hay información de billetera disponible');
    }

    try {
      await _billeteraService.retirarSaldo(
        billeteraId: _saldo!.billeteraId,
        monto: monto,
        concepto: concepto,
      );

      // Recargar saldo y movimientos después del retiro
      await cargarSaldo();
      await cargarMovimientos();
    } catch (e) {
      print('❌ [ChoferBilleteraProvider] Error retirando saldo: $e');
      rethrow;
    }
  }

  // Limpiar estado (para logout)
  void limpiarEstado() {
    _saldo = null;
    _loadingSaldo = false;
    _error = null;
    _movimientos = [];
    _loadingMovimientos = false;
    _errorMovimientos = null;
    notifyListeners();
  }
}

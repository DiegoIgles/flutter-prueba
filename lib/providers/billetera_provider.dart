// BilleteraProvider.dart
import 'dart:async'; // <— para Timer
import 'package:flutter/foundation.dart';
import '../services/billetera_service.dart';
import '../models/billetera.dart';
import '../models/movimiento.dart';

class BilleteraProvider extends ChangeNotifier {
  final BilleteraService _billeteraService = BilleteraService();

  // ------ Estado de saldo/movimientos ------
  BilleteraSaldoResponse? _saldo;
  bool _loadingSaldo = false;
  String? _error;

  bool _qrVerificando = false; // evita /verificar solapados
  bool _qrFinalizado = false; // ya terminamos (completado/expirado)

  List<Movimiento> _movimientos = [];
  bool _loadingMovimientos = false;
  String? _errorMovimientos;

  BilleteraSaldoResponse? get saldo => _saldo;
  bool get loadingSaldo => _loadingSaldo;
  String? get error => _error;

  List<Movimiento> get movimientos => _movimientos;
  bool get loadingMovimientos => _loadingMovimientos;
  String? get errorMovimientos => _errorMovimientos;

  // ------ NUEVO: Estado de recarga por QR ------
  Timer? _qrTimer;
  int? _qrMovimientoId;
  String? _qrDataUrl; // "data:image/png;base64,..."
  String _qrEstado = 'Pendiente';
  bool _qrProcesando = false;
  String? _qrError;

  // getters para la UI
  String? get qrDataUrl => _qrDataUrl;
  String get qrEstado => _qrEstado;
  bool get qrProcesando => _qrProcesando;
  String? get qrError => _qrError;
  bool get qrEnCurso =>
      _qrMovimientoId != null && _qrEstado.toLowerCase() == 'pendiente';

  // ================== Saldo / Movs ==================
  Future<void> cargarSaldo() async {
    if (_loadingSaldo) return;
    _loadingSaldo = true;
    _error = null;
    notifyListeners();

    try {
      final clienteId = await _billeteraService.getClienteIdFromToken();
      if (clienteId != null) {
        _saldo = await _billeteraService.getSaldo(clienteId);
        _error = null;
      } else {
        _error = 'No se pudo obtener el ID del cliente';
      }
    } catch (e) {
      _error = 'Error al cargar saldo: $e';
    } finally {
      _loadingSaldo = false;
      notifyListeners();
    }
  }

  Future<void> cargarMovimientos() async {
    if (_loadingMovimientos) return;
    _loadingMovimientos = true;
    _errorMovimientos = null;
    notifyListeners();

    try {
      final clienteId = await _billeteraService.getClienteIdFromToken();
      if (clienteId != null) {
        _movimientos = await _billeteraService.getMovimientos(clienteId);
        _errorMovimientos = null;
      } else {
        _errorMovimientos = 'No se pudo obtener el ID del cliente';
      }
    } catch (e) {
      _errorMovimientos = 'Error al cargar movimientos: $e';
    } finally {
      _loadingMovimientos = false;
      notifyListeners();
    }
  }

  // ================== NUEVO: Flujo de QR ==================

  /// 1) Genera el QR y arranca polling contra /qr/verificar
  Future<void> iniciarRecargaConQr({
  required double monto,
  String? vigencia,
  bool usoUnico = true,
  Duration intervalo = const Duration(seconds: 3),
  String? detalle,
}) async {
  _qrError = null;
  _qrProcesando = true;

  // ⬇️ limpiar cualquier flujo previo
  _qrTimer?.cancel();
  _qrFinalizado = false;
  _qrVerificando = false;
  _qrEstado = 'Pendiente';
  _qrDataUrl = null;
  notifyListeners();

  final det = detalle ?? 'Recarga desde app - ${monto.toStringAsFixed(2)} BOB';

  try {
    final resp = await _billeteraService.generarQr(
      monto: double.parse(monto.toStringAsFixed(2)),
      vigencia: vigencia,
      usoUnico: usoUnico,
      detalle: det,
    );
    final data = resp['Data'] as Map<String, dynamic>;
    _qrMovimientoId = data['movimiento_id'] as int;
    _qrDataUrl = data['qr'] as String;

    _qrProcesando = false;
    notifyListeners();

    // ⬇️ arranca polling
    _qrTimer = Timer.periodic(intervalo, (_) => _verificarQrUnaVez());
  } catch (e) {
    _qrProcesando = false;
    _qrError = 'Error generando QR: $e';
    notifyListeners();
  }
}

  /// 2) Verifica una vez; si completa, para timer y refresca saldo/movs
  Future<void> _verificarQrUnaVez() async {
  // ⬇️ no dispares si no hay id, ya finalizó o hay una verificación en curso
  if (_qrMovimientoId == null || _qrFinalizado || _qrVerificando) return;

  _qrVerificando = true;
  try {
    final res = await _billeteraService.verificarQr(
      movimientoId: _qrMovimientoId!,
    );
    final data = res['Data'] as Map<String, dynamic>;
    _qrEstado = (data['estado'] as String?) ?? 'Pendiente';
    notifyListeners();

    final estadoLower = _qrEstado.toLowerCase();
    if (estadoLower == 'completado') {
      _qrFinalizado = true;          // ⬅️ marca terminado
      _qrTimer?.cancel();            // ⬅️ detén polling
      await cargarSaldo();           // refresca vista
      await cargarMovimientos();
    } else if (estadoLower == 'expirado') {
      _qrFinalizado = true;
      _qrTimer?.cancel();
    }
  } catch (e) {
    _qrError = 'Error verificando QR: $e';
    notifyListeners();
  } finally {
    _qrVerificando = false;          // ⬅️ libera el candado
  }
}


  /// 3) Cancela/limpia el flujo de QR (al cerrar modal, etc.)
 void cancelarRecargaQr() {
  _qrTimer?.cancel();
  _qrMovimientoId = null;
  _qrDataUrl = null;
  _qrEstado = 'Pendiente';
  _qrError = null;
  _qrProcesando = false;

  // ⬇️ asegúrate de cortar cualquier verificación pendiente
  _qrVerificando = false;
  _qrFinalizado = true;

  notifyListeners();
}

  // ================== Helpers ==================
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearErrorMovimientos() {
    _errorMovimientos = null;
    notifyListeners();
  }
}

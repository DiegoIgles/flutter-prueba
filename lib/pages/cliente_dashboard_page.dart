import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba/services/ticket_service.dart';
import '../services/auth_service.dart';
import '../models/cliente.dart';
import '../providers/billetera_provider.dart';
import 'cliente_billetera_page.dart';
import 'cliente_perfil_page.dart';
import 'cliente_movimientos_page.dart';
import 'package:prueba/widgets/ubicacion_modal.dart';
import 'ubicacion_page.dart';
import 'package:prueba/services/cliente_sockets.dart';

class ClienteDashboardPage extends StatefulWidget {
  final String token;
  final Cliente? cliente;

  const ClienteDashboardPage({
    super.key,
    required this.token,
    this.cliente,
  });

  @override
  State<ClienteDashboardPage> createState() => _ClienteDashboardPageState();
}

class _ClienteDashboardPageState extends State<ClienteDashboardPage> {
  final AuthService _authService = AuthService();
  late ClienteSockets clienteSockets;

  Cliente? _clienteInfo;
  int _selectedIndex = 0;
  bool _choferCercano = false; // Para controlar si hay chofer cerca

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    clienteSockets = ClienteSockets();
    clienteSockets.start(widget.token, context);
    _clienteInfo = widget.cliente;
    _initializePages();

    // Cargar saldo usando el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BilleteraProvider>(context, listen: false).cargarSaldo();
    });

    _simularProximidadChofer(); // Simular detección de chofer cercano
  }

  @override
  void dispose() {
    clienteSockets.dispose();
    super.dispose();
  }

  void _mostrarUbicacionModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UbicacionModal(token: widget.token),
    );
  }

  void _initializePages() {
    _pages.addAll([
      _buildHomePage(),
      const ClienteBilleteraPage(),
      const ClienteMovimientosPage(),
      ClientePerfilPage(cliente: _clienteInfo),
    ]);
  }

  // Simular detección de chofer cercano para demo
  void _simularProximidadChofer() {
    // En producción, esto sería una funcionalidad real de geolocalización
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _choferCercano = true;
        });
        // _mostrarAlertaChoferCercano();
      }
    });
  }

  void _mostrarAlertaChoferCercano() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.directions_car, color: Color(0xFF197B9C)),
            SizedBox(width: 8),
            Text('Chofer detectado'),
          ],
        ),
        content: const Text(
          'Hay un chofer cerca de tu ubicación. ¿Deseas realizar un pago?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _choferCercano = false);
            },
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _procesarPagoChofer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF197B9C),
            ),
            child: const Text('Pagar ahora',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _procesarPagoChofer() {
    // Simulación de pago a chofer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pago procesado'),
        content: const Text('El pago al chofer se ha realizado exitosamente.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refrescarSaldo(); // Actualizar saldo
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _refrescarSaldo() {
    Provider.of<BilleteraProvider>(context, listen: false).cargarSaldo();
  }

  Future<void> _logout() async {
    await _authService.logout(chofer: false);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), // Reducido padding top
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo personalizado
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF197B9C), Color(0xFF0B0530)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Bienvenido! 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_clienteInfo != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_clienteInfo!.nombre} ${_clienteInfo!.apellido}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Saldo de billetera
          Consumer<BilleteraProvider>(
            builder: (context, billeteraProvider, child) {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF197B9C),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saldo disponible',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            billeteraProvider.loadingSaldo
                                ? const Text(
                                    'Cargando...',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B0530),
                                    ),
                                  )
                                : Text(
                                    '${billeteraProvider.saldo?.saldo ?? '0.00'} ${billeteraProvider.saldo?.moneda ?? 'BOB'}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B0530),
                                    ),
                                  ),
                            if (billeteraProvider.error != null)
                              Text(
                                billeteraProvider.error!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: billeteraProvider.loadingSaldo ? null : _refrescarSaldo,
                        icon: billeteraProvider.loadingSaldo
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF197B9C),
                                ),
                              )
                            : const Icon(Icons.refresh),
                        color: const Color(0xFF197B9C),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Alerta de chofer cercano (si está activa)
          if (_choferCercano) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      color: Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chofer detectado cerca',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toca para realizar un pago',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _mostrarAlertaChoferCercano,
                      icon: const Icon(
                        Icons.payment,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Accesos rápidos
          const Text(
            'Accesos rápidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.add_card,
                  title: 'Cargar saldo',
                  subtitle: 'Escanear QR',
                  onTap: () => _onItemTapped(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.history,
                  title: 'Movimientos',
                  subtitle: 'Ver historial',
                  onTap: () => _onItemTapped(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UbicacionPage(token: widget.token),
                ),
              );
            },
            icon: const Icon(Icons.my_location),
            label: const Text('Ver ubicación en tiempo real'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF197B9C),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          // Lista de tickets recibidos por socket
          const SizedBox(height: 20),
          Text(
            'Ofertas de viaje',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 340,
            child: _buildTicketList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: const Color(0xFF197B9C),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: clienteSockets.ticketsNotifier,
      builder: (context, tickets, _) {
        // Filtrar tickets con monto o estado nulo
        final filteredTickets = tickets.where((t) => t['monto'] != null && t['estado'] != null).toList();
        if (filteredTickets.isEmpty) {
          return const Text('No hay ofertas de viaje');
        }
        return SizedBox(
          height: 340,
          child: Scrollbar(
            radius: const Radius.circular(12),
            thickness: 6,
            thumbVisibility: true,
            child: ListView.separated(
              itemCount: filteredTickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final t = filteredTickets[i];
                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icono removido para más espacio
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Modelo como título principal
                              Text(
                                t['vehiculo_modelo'] ?? 'Modelo desconocido',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF0B0530),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // Placa y tipo de vehículo en una fila
                              Row(
                                children: [
                                  Icon(Icons.confirmation_number, color: Colors.blueGrey.shade400, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    t['vehiculo_placa'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(Icons.directions_car, color: Colors.blueGrey, size: 16),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      t['tipo_nombre'] ?? '-',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              // Nombre del chofer
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Color(0xFF197B9C), size: 16),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      t['chofer_nombre'] ?? '-',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF197B9C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              // Monto y estado (solo si no es pendiente)
                              Row(
                                children: [
                                  const Icon(Icons.attach_money, color: Colors.green, size: 16),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${t['monto']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                  if (t['estado'] != 'pendiente') ...[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.info_outline, color: Colors.orange, size: 15),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${t['estado']}'.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: t['estado'] == 'activo' ? Colors.blue : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final clienteId = _clienteInfo?.id;
                            if (clienteId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No se encontró el ID del cliente.')),
                              );
                              return;
                            }
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator()),
                              );
                              final resp = await TicketService.pagarTicket(
                                ticketOfferId: t['ticket_id'],
                                clienteId: clienteId,
                                token: widget.token,
                              );
                              Navigator.of(context).pop(); // Cerrar loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('¡Pago realizado! Ticket #${resp['ticket_id']}')),
                              );
                              // Emitir evento socket para notificar al chofer
                              clienteSockets.socket.emit('ticket_paid', {
                                'ticket_id': t['ticket_id'],
                                'cliente_id': clienteId,
                              });
                              _refrescarSaldo();
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al pagar: $e')),
                              );
                            }
                          },
                          icon: const Icon(Icons.payment, size: 20),
                          label: const Text('Pagar', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF197B9C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0530), Color(0xFF197B9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getAppBarTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_clienteInfo != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${_clienteInfo!.nombre} ${_clienteInfo!.apellido}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  color: Colors.white,
                  tooltip: 'Cerrar sesión',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildCustomHeader(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF197B9C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Billetera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Movimientos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Billetera';
      case 2:
        return 'Movimientos';
      case 3:
        return 'Perfil';
      default:
        return 'App';
    }
  }
}

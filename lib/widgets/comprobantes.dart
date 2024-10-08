import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunmi/hive/ticket.dart';

import 'package:sunmi/providers/cart_provider.dart';
import 'package:sunmi/widgets/comprobantes_details.dart';

class OrdenesScreen extends StatefulWidget {
  @override
  _OrdenesScreenState createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  late Future<List<Map<String, dynamic>>> _ordenesConTickets;

  @override
  void initState() {
    super.initState();
    // Inicializamos _ordenesConTickets
    _ordenesConTickets = obtenerOrdenesConTickets();
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Órdenes'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordenesConTickets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar órdenes: ${snapshot.error}'));
          } else if (snapshot.data?.isEmpty ?? true) {
            return Center(child: Text('No hay órdenes disponibles'));
          }

          // Si hay órdenes, las mostramos en una lista
          var ordenes = snapshot.data;

          return ordenes == null || ordenes.isEmpty
              ? Center(
                  child: Text('No hay órdenes disponibles'),
                )
              : ListView.builder(
                  itemCount:
                      ordenes.length, // Aseguramos que ordenes no sea null
                  itemBuilder: (context, index) {
                    var orden = ordenes[index];
                    return ListTile(
                      title: Text('Orden: ${orden['cartId']}'),
                      subtitle: Text(
                          'Fecha: ${orden['fecha'] ?? 'Fecha no disponible'}'),
                      onTap: () {
                        // Navegar a la pantalla de detalles
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyTicketView(),
                          ),
                        );
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}

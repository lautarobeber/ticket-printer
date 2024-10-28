import 'package:flutter/material.dart';
import 'package:sunmi/providers/cart_provider.dart';
import 'package:ticket_widget/ticket_widget.dart';

/* class DetallesOrdenScreen extends StatelessWidget {
  final Map<String, dynamic> orden;

  DetallesOrdenScreen({required this.orden});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Orden ${orden['cartId']}'),
      ),
      body: ListView.builder(
        itemCount: orden['tickets'].length,
        itemBuilder: (context, index) {
          var ticketConCantidad = orden['tickets'][index];
          var ticket = ticketConCantidad['ticket'];
          var cantidad = ticketConCantidad['cantidad'];

          return ListTile(
            title: Text('Ticket: ${ticket?.name ?? 'Ticket no disponible'}'),
            subtitle: Text('Cantidad: $cantidad'),
          );
        },
      ),
    );
  }
} */

class MyTicketView extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  final String ordenId;
  final String date;

  MyTicketView(
      {required this.tickets, required this.ordenId, required this.date});

  @override
  Widget build(BuildContext context) {
    print(tickets);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket'),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: TicketWidget(
          width: 350,
          height: 500,
          isCornerRounded: true,
          padding: const EdgeInsets.all(20),
          child: TicketData(tickets: tickets, ordenId: ordenId, date: date),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí puedes agregar la lógica para eliminar el ticket
          _showConfirmationDialog(context);

          // Lógica para eliminar el ticket
        },
        backgroundColor: Colors.red, // Cambia el color si es necesario
        child: const Icon(Icons.delete), // Icono del botón de papelera
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Introduce la contraseña de SuperAdmin para confirmar la eliminación:'),
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(), // Cerrar el diálogo
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              String password = passwordController.text;

              if (password == '5678') {
                deleteOrderById(ordenId);

                // Cerrar el diálogo primero
                Navigator.of(dialogContext).pop();

                // Cerrar la pantalla de detalles y pasar el result como true
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Contraseña incorrecta.')),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

class TicketData extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  final String ordenId;
  final String date;
  const TicketData(
      {Key? key,
      required this.tickets,
      required this.ordenId,
      required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Información del ticket y la fecha
        Text(
          'ID Ticket: $ordenId',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Fecha/Hora $date',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Encabezados de la tabla
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(
                flex: 2,
                child: Center(
                    child: Text('Artículo',
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            Expanded(
                flex: 1,
                child: Center(
                    child: Text('Cant.',
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            Expanded(
                flex: 1,
                child: Center(
                    child: Text('Precio',
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            Expanded(
                flex: 1,
                child: Center(
                    child: Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ),
        Divider(color: Colors.black),

        // Datos de cada ticket
        for (var ticket in tickets)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(child: Text(ticket['name'] ?? '')),
                ),
                Expanded(
                  flex: 1,
                  child: Center(child: Text('${ticket['cantidad']}')),
                ),
                Expanded(
                  flex: 1,
                  child: Center(child: Text('${ticket['price']}')),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                      child: Text('${ticket['cantidad'] * ticket['price']}')),
                ),
              ],
            ),
          ),

        Divider(color: Colors.black),

        // Total final
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            'Total \$ ${tickets.fold<double>(0, (sum, ticket) => sum + ticket['cantidad'] * ticket['price'])}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

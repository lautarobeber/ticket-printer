import 'package:flutter/material.dart';
import 'package:sunmi/hive/ticket.dart';

import 'package:sunmi/providers/tickets_provider.dart';
import 'package:sunmi/widgets/update_screen.dart';

class ListarScreen extends StatefulWidget {
  static const nameRoute = 'listar';

  @override
  _ListarState createState() => _ListarState();
}

class _ListarState extends State<ListarScreen> {
  var ticketsProvider = TicketsProvider();

  @override
  void dispose() {
    super.dispose();
    ticketsProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listar Tickets'),
      ),
      body: FutureBuilder<List<Ticket>>(
        future: ticketsProvider
            .getTickets(), // Asegúrate de que este método devuelva Future<List<Ticket>>
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapShot.hasError) {
            return Center(child: Text('Error: ${snapShot.error}'));
          } else if (snapShot.hasData && snapShot.data!.isEmpty) {
            return Center(
              child: const Text(
                'No hay tickets',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          } else {
            // Aquí pasas la lista de tickets
            return _getTickets(context, snapShot.data!);
          }
        },
      ),
      floatingActionButton: IconButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateScreen(
                ticket: Ticket(id: 0, name: '', price: 0.0),
                indiceTicket: null,
                guardar: true,
              ),
            ),
          );

          if (result == true) {
            setState(() {});
          }
        },
        icon: Icon(Icons.add_circle),
      ),
    );
  }

  ListView _getTickets(BuildContext context, List<Ticket> tickets) {
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, ticketsIndex) {
        var ticketIndividual =
            tickets[ticketsIndex]; // Cambia 'id' por 'ticketsIndex'
        return Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black38)),
          child: ListTile(
            title: GestureDetector(
              child: Text(
                '${ticketIndividual.name}\nPrecio: ${ticketIndividual.price}', // Cambia 'ticket' por 'ticketIndividual'
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateScreen(
                      ticket:
                          ticketIndividual, // Cambia 'ticket' por 'ticketIndividual'
                      indiceTicket: ticketIndividual.id,
                      guardar: false,
                    ),
                  ),
                );
              },
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteTicket(ticketIndividual.id);
                // Cambia 'ticket' por 'ticketIndividual'
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }

  void _deleteTicket(int id) {
    ticketsProvider.deleteTicket(id);
  }
}

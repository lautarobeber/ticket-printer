import 'package:flutter/material.dart';
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
  const MyTicketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: TicketWidget(
          width: 350,
          height: 500,
          isCornerRounded: true,
          padding: EdgeInsets.all(20),
          child: TicketData(),
        ),
      ),
    );
  }
}

class TicketData extends StatelessWidget {
  const TicketData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 120.0,
              height: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(width: 1.0, color: Colors.green),
              ),
              child: const Center(
                child: Text(
                  'Comprobante',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
            Row(
              children: [
                
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'ID DE LA ORDEN',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            'Tickets',
            style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ticketDetailsWidget('TIPO', 'Hafiz M Mujahid', 'Fecha', '28-08-2022'),
              //AL TICKET DETAILS LE FALTA PRECIO, CANTIDAD y TOTAL
              
            ],
          ),
        ),
       
        const Padding(
          padding: EdgeInsets.only(top: 20.0, left: 75.0, right: 75.0),
          child: Text(
            '+54 3455 227681',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 30),
        const Text('         250 A FONDO')
      ],
    );
  }
}

Widget ticketDetailsWidget(String firstTitle, String firstDesc, String secondTitle, String secondDesc) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              firstTitle,
              style: const TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                firstDesc,
                style: const TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              secondTitle,
              style: const TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                secondDesc,
                style: const TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      )
    ],
  );
}



import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sunmi/hive/ticket.dart';
import 'package:sunmi/providers/tickets_provider.dart';
import 'package:sunmi/widgets/home_screen.dart';
import 'package:uuid/uuid.dart';
import 'list_tickets.dart';
import 'dart:math';

class UpdateScreen extends StatefulWidget {
  static const nameRoute = 'update';
  final ticket;
  final int? indiceTicket;
  final bool guardar;

  UpdateScreen(
      {required this.ticket,
      required this.indiceTicket,
      required this.guardar});

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  // final _controller = ScrollController();

  var ticketProvider = TicketsProvider();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String generateTicketId() {
    var uuid = Uuid().v4();

    // Convertir el UUID a bytes (sin guiones)
    var uuidBytes = utf8.encode(uuid);

    // Codificar en Base64 y limitar a los primeros 12 caracteres
    var id_ticketEncoded = base64UrlEncode(uuidBytes).substring(0, 12);
    return id_ticketEncoded;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
          title: widget.indiceTicket != null
              ? Text('Actualizar Ticket')
              : Text("Crear Ticket")),
      body: Form(
        key: formKey,
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nombre'),
                  initialValue:
                      widget.indiceTicket != null ? widget.ticket.name : '',
                  onSaved: (newName) {
                    if (widget.indiceTicket == null) {
                      // Solo generar un nuevo ID si es un ticket nuevo
                      widget.ticket.id = generateTicketId();
                     
                    }
                    print(widget.ticket.id);
                    widget.ticket.name = newName!;
                  },
                ),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    initialValue: widget.indiceTicket != null
                        ? widget.ticket.price.toString()
                        : '',
                    onSaved: (newPrice) {
                      if (newPrice != null && newPrice.isNotEmpty) {
                        // Intentar convertir a double
                        double? parsedPrice = double.tryParse(newPrice);
                        if (parsedPrice != null) {
                          widget.ticket.price =
                              parsedPrice; // Asignar el valor convertido
                        } else {
                          // Manejo de error: el precio no es un número válido
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Por favor, ingrese un precio válido.')),
                          );
                        }
                      }
                    }),
              ],
            )),
      ),
      floatingActionButton: IconButton(
          onPressed: () {
            formKey.currentState!.save();
            (widget.guardar)
                ? _addTicket(widget.ticket)
                : _updateTicket(widget.ticket.id, widget.ticket);
          },
          icon: Icon(Icons.save)),
    );
  }

  _addTicket(var ticket) {
    ticketProvider.addTicket(ticket);

    Navigator.pop(context, true);
  }

  _updateTicket(var id, var ticket) async {
    ticketProvider.updateTicket(widget.ticket.id, widget.ticket);
    Navigator.pop(context, true);
  }
}

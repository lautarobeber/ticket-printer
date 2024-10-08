import 'package:flutter/material.dart';
import 'package:sunmi/hive/ticket.dart';
import 'package:sunmi/providers/tickets_provider.dart';
import 'package:sunmi/widgets/home_screen.dart';
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
                    // Validamos que newName no sea null
                    widget.ticket.id = _generarIdAleatorio();
                    widget.ticket.name = newName!;
                  },
                ),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Price'),
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

  int _generarIdAleatorio() {
    return Random().nextInt(100000); // Generar un ID aleatorio
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
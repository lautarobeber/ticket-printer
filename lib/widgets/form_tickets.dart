import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
import 'package:sunmi/hive/ticket.dart';
import 'package:uuid/uuid.dart';



class TicketForm extends StatefulWidget {
  @override
  _TicketFormState createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketForm> {
  final _formKey = GlobalKey<FormState>();
  String _ticketName = '';
  double _ticketPrice = 0.0;
  var uuid = Uuid();

  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {

    
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Guardar los valores del formulario


      //var uuid = Uuid(); id unico
      // Crear el ticket y guardarlo en Hive
      
      Ticket newTicket = Ticket(id: uuid.v4(), name: _ticketName, price: _ticketPrice);
      //await HiveData().saveTicket(newTicket);

      // Limpiar los campos después de guardar
      _nameController.clear();
      _priceController.clear();


    
      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket agregado con éxito')),

        
      );
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Campo para el nombre del ticket
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre del Ticket'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
              onSaved: (value) {
                _ticketName = value!;
              },
            ),
            
            // Campo para el precio del ticket
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Precio del Ticket'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un precio';
                }
                if (double.tryParse(value) == null) {
                  return 'Por favor ingresa un número válido';
                }
                return null;
              },
              onSaved: (value) {
                _ticketPrice = double.parse(value!);
              },
            ),
            
            SizedBox(height: 20),
            
            // Botón para enviar el formulario
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Agregar Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}

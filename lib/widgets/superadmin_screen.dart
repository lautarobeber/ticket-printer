import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sunmi/hive/credito.dart';
import 'package:sunmi/hive/empresa.dart';
import 'package:sunmi/providers/cart_provider.dart';
import 'package:sunmi/providers/credito_provider.dart';
import 'package:sunmi/providers/empresa_provider.dart';
import 'package:sunmi/sunmi.dart';

class SuperAdminScreen extends StatefulWidget {
  @override
  _SuperAdminScreenState createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final TextEditingController creditLimitController = TextEditingController();
  String? _title;
  String? _pointSale;
  String? _seller;
  var _ticketsZ;
  Uint8List? _imageBytes;
  Sunmi printer = Sunmi();

  @override
  void initState() {
    super.initState();
    _cargarEmpresa();
    _cargarTicketsZ();
    _cargarCredito();
  }

  // Función para cargar la empresa desde Hive
  Future<void> _cargarEmpresa() async {
    Empresa? empresa =
        await getEmpresa(); // Ahora empresa será de tipo Empresa?

    if (empresa != null) {
      // Si se encontró una empresa, asigna los valores a los controladores
      setState(() {
        _title = empresa.title; // Titulo
        _pointSale = empresa.pointSale; // Punto de venta
        _seller = empresa.seller; // Vendedor
        _imageBytes = empresa.imageBytes; // Imagen (si es necesaria)
      });
    } else {
      // Manejo en caso de que no se encuentre ninguna empresa
      print('No se encontraron empresas en la base de datos');
    }
  }

  Future<void> _cargarCredito() async {
    Credito? credito =
        await getCredito(); // Ahora empresa será de tipo Empresa?

    if (credito != null) {
      // Si se encontró una empresa, asigna los valores a los controladores
      setState(() {
        creditLimitController.text = credito.credit; // Imagen (si es necesaria)
      });
    } else {
      // Manejo en caso de que no se encuentre ninguna empresa
      print('No se encontro limite de credito');
      setState(() {
        creditLimitController.text =
            '99999999999999'; // Imagen (si es necesaria)
      });
    }
  }

  Future<void> _guardarCredito() async {
    final String creditoTexto = creditLimitController.text;

    if (creditoTexto.isNotEmpty) {
      Credito nuevoCredito = Credito(
        id: 0054,
        credit: creditoTexto,
      );

      bool success = await agregarCredito(nuevoCredito);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Crédito guardado exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el crédito')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa un valor para el crédito')),
      );
    }
  }

  Future<void> _cargarTicketsZ() async {
    _ticketsZ = await getCajaZ(); // Ahora empresa será de tipo Empresa?

    if (_ticketsZ != null) {
      // Si se encontró una empresa, asigna los valores a los controladores
      print('Se encontraron los ticketz para la caja');
    } else {
      // Manejo en caso de que no se encuentre ninguna empresa
      print('No se encontraron los ticketz para la caja');
    }
  }

  void _cancelForm() {
    // Limpiar los campos del formulario
    Navigator.pop(context);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content:
              Text('¿Estás seguro de que deseas eliminar todos los tickets?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () async {
                // Aquí va la lógica para eliminar los tickets de manera asíncrona
                await vaciarCart(); // Espera a que se eliminen los tickets
                await _cargarTicketsZ(); // Vuelve a cargar los tickets después de eliminar
                Navigator.of(context).pop(); // Cierra el diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Todos los tickets han sido eliminados')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperAdmin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de límite de crédito
            TextField(
              controller: creditLimitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Límite Crédito',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Botones Guardar y Cancelar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _guardarCredito();
                  },
                  child: const Text('Guardar'),
                ),
                OutlinedButton(
                  onPressed: () {
                    _cancelForm(); // Limpia el campo de texto
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Botón circular de CAJA
            SizedBox(
              width: 80, // Ancho deseado
              height: 80, // Alto deseado
              child: FloatingActionButton(
                onPressed: () {
                  printer.printReceipt(_ticketsZ, _pointSale, _seller);
                },
                backgroundColor: Colors.red,
                child: const Text(
                  'CAJA',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // Botón rectangular de BORRAR TODOS LOS TICKETS
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Fondo rojo
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
                child: const Text(
                  'BORRAR TODOS LOS TICKETS',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

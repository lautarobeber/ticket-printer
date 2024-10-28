import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunmi/hive/empresa.dart';
import 'package:sunmi/providers/cart_provider.dart';
import 'package:sunmi/providers/empresa_provider.dart';
import 'package:sunmi/sunmi.dart';

import 'package:sunmi/widgets/form_tickets.dart';
import 'package:sunmi/widgets/list_tickets.dart';
import 'package:uuid/uuid.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController field1Controller = TextEditingController();
  final TextEditingController field2Controller = TextEditingController();
  final TextEditingController field3Controller = TextEditingController();
  late Box<Empresa> empresaBox;
  Sunmi printer = Sunmi();

  final String? _id = '004';
  String? _title;
  String? _pointSale;
  String? _seller;
  var _ticketsZ;
  Uint8List? _imageBytes;
  var totalTicketsZ = 0;
  @override
  void initState() {
    super.initState();
    _cargarEmpresa();
    _cargarTicketsZ();
  }

  // Función para cargar la empresa desde Hive
  void _cargarEmpresa() async {
    Empresa? empresa =
        await getEmpresa(); // Ahora empresa será de tipo Empresa?

    if (empresa != null) {
      // Si se encontró una empresa, asigna los valores a los controladores
      setState(() {
        field1Controller.text = empresa.title; // Titulo
        field2Controller.text = empresa.pointSale; // Punto de venta
        field3Controller.text = empresa.seller; // Vendedor
        _imageBytes = empresa.imageBytes; // Imagen (si es necesaria)
      });
    } else {
      // Manejo en caso de que no se encuentre ninguna empresa
      print('No se encontraron empresas en la base de datos');
    }
  }
  void _cargarTicketsZ() async {
    _ticketsZ  =
        await getCajaZ(); // Ahora empresa será de tipo Empresa?

    if ( _ticketsZ != null) {
      // Si se encontró una empresa, asigna los valores a los controladores
      print('Se encontraron los ticketz para la caja');
    } else {
      // Manejo en caso de que no se encuentre ninguna empresa
      print('No se encontraron los ticketz para la caja');
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Realizar la acción de guardar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Formulario guardado'),
      ));
    }
  }

  // Función para seleccionar una imagen
  Future<void> seleccionarImagen() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? imagenSeleccionada =
        await _picker.pickImage(source: ImageSource.gallery);

    if (imagenSeleccionada != null) {
      Uint8List bytes = await imagenSeleccionada.readAsBytes();
      setState(() {
        _imageBytes = bytes; // Guardamos los bytes de la imagen
      });
    }
  }
  Future<void> printZ() async {
   /* cajaZ( _imageBytes); */
   printer.printReceipt(_ticketsZ, _pointSale, _seller);
  }

  // Guardar el formulario en Hive
  Future<void> guardarEmpresa() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Guardar el estado actual del formulario

      // Obtener valores desde los controladores
      String title = field1Controller.text; // Titulo
      String pointSale = field2Controller.text; // Punto de venta
      String seller = field3Controller.text; // Vendedor

      // Asegúrate de que _imageBytes no sea nulo
      if (_imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Por favor seleccione una imagen'),
        ));
        return;
      }
      //GUARDE UNO PERO AHORA QUIERO QUE SE ACTUALICE SOLAMENTE

      Empresa nuevaEmpresa = Empresa(
        id: _id!, // Usar el ID existente
        title: title,
        imageBytes: _imageBytes!,
        pointSale: pointSale,
        seller: seller,
      );

      // Guardar la empresa en Hive
      bool result = await agregarEmpresa(nuevaEmpresa);

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Empresa guardada exitosamente'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar la empresa'),
        ));
      }

      print('Empresa guardada exitosamente');
    }
  }

  void _cancelForm() {
    // Limpiar los campos del formulario
    Navigator.pop(context);
  }

  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: field1Controller,
                    decoration: InputDecoration(labelText: 'Titulo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese texto';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: field2Controller,
                    decoration: InputDecoration(labelText: 'Punto de Venta'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese texto';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: field3Controller,
                    decoration: InputDecoration(labelText: 'Vendedor'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese texto';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: seleccionarImagen,
                    child: Text('Seleccionar Logo'),
                  ),
                  SizedBox(height: 10),
                  // Mostrar la imagen seleccionada
                  _imageBytes != null
                      ? Image.memory(_imageBytes!, height: 200)
                      : Text('No se ha seleccionado ninguna imagen'),
                  SizedBox(height: 20),
                  // Botón para guardar el formulario

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: guardarEmpresa,
                        child: Text('Guardar'),
                      ),
                      ElevatedButton(
                        onPressed: _cancelForm,
                        child: Text('Cancelar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListarScreen()),
                    );
                  },
                  child: Text('Artículos'),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(40),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print(_ticketsZ);
                    printer.printReceipt(_ticketsZ, _pointSale, _seller);
                  },
                  child: Text('Caja'),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(40),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//ADMIN SCREEN
/* class AdminScreen extends StatelessWidget {
  
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navegar a la nueva pantalla "Artículos"
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListarScreen()),
            );
          },
          child: const Text('Ir a Artículos'),
        ),
      ),
    );
  }
} */

/* class ArticulosScreen extends StatefulWidget {
  @override
  _ArticulosScreenState createState() => _ArticulosScreenState();
}

// Nueva pantalla para mostrar "Artículos"
class _ArticulosScreenState extends State<ArticulosScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    )
} */

import 'package:flutter/material.dart';
import 'package:sunmi/widgets/comprobantes.dart';
import './admin_screen.dart';

// Widget del Drawer
class AppDrawer extends StatelessWidget {
  final VoidCallback loadTickets; // Define el tipo de la función que recibirás.

  const AppDrawer({Key? key, required this.loadTickets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menú',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navegar a la página de inicio si es necesario
            },
          ),
          ListTile(
            title: const Text('Administrador'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              _showPasswordDialog(context); // Muestra el diálogo de contraseña
            },
          ),
          ListTile(
            title: const Text('Comprobantes'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navegar a la pantalla de comprobantes
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrdenesScreen(), // Cambia 'OrdenesScreen' por el nombre de tu página de comprobantes
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//AdminScreen Password

void _showPasswordDialog(BuildContext context) {
  final TextEditingController passwordController =
      TextEditingController(); // Controlador para el campo de texto
  String password = ''; // Variable para almacenar la contraseña
  String? errorMessage; // Variable para el mensaje de error

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        // Para poder usar setState dentro del diálogo
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Contraseña de Administrador'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      passwordController, // Usa el controlador para obtener el valor del input
                  keyboardType: TextInputType.number, // Solo permite números
                  obscureText: true, // Oculta la contraseña mientras se escribe
                  decoration: InputDecoration(
                    hintText: 'Contraseña numérica',
                    errorText:
                        errorMessage, // Muestra el mensaje de error si no es nulo
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
              ),
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  // Lógica para verificar la contraseña
                  password =
                      passwordController.text; // Obtiene el valor ingresado

                  if (password == '1234') {
                    // Cambia '1234' a la contraseña que desees
                    Navigator.of(context).pop(); // Cierra el diálogo
                    // Navega a la pantalla de admin
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminScreen()),
                    );
                  } else {
                    // Actualiza el estado con el mensaje de error
                    setState(() {
                      errorMessage = 'Contraseña incorrecta';
                    });
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:sunmi/widgets/comprobantes.dart';
import './admin_screen.dart';
import './superadmin_screen.dart'; // Asegúrate de importar la pantalla de SuperAdmin

class AppDrawer extends StatelessWidget {
  final VoidCallback loadTickets;

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
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Administrador'),
            onTap: () {
              Navigator.pop(context);
              _showPasswordDialog(context, 'admin'); // Especifica el destino
            },
          ),
          ListTile(
            title: const Text('SuperAdmin'),
            onTap: () {
              Navigator.pop(context);
              _showPasswordDialog(context, 'superadmin'); // Especifica el destino
            },
          ),
          ListTile(
            title: const Text('Comprobantes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdenesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Función genérica de diálogo de contraseña
void _showPasswordDialog(BuildContext context, String destination) {
  final TextEditingController passwordController = TextEditingController();
  String password = '';
  String? errorMessage;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(destination == 'admin'
                ? 'Contraseña de Administrador'
                : 'Contraseña de SuperAdmin'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña numérica',
                    errorText: errorMessage,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  password = passwordController.text;

                  if ((destination == 'admin' && password == '1234') ||
                      (destination == 'superadmin' && password == '5678')) {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => destination == 'admin'
                            ? AdminScreen()
                            : SuperAdminScreen(),
                      ),
                    );
                  } else {
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

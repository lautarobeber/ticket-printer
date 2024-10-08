import 'package:flutter/material.dart';

import 'package:sunmi/widgets/form_tickets.dart';
import 'package:sunmi/widgets/list_tickets.dart';

//ADMIN SCREEN
class AdminScreen extends StatelessWidget {
  
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
}

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

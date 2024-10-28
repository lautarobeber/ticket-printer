import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunmi/hive/cart.dart';
import 'package:sunmi/hive/credito.dart';
import 'package:sunmi/hive/empresa.dart';
import 'package:sunmi/hive/ticket.dart';
import 'package:sunmi/providers/cart_provider.dart';
import 'package:sunmi/providers/empresa_provider.dart';
import 'package:sunmi/widgets/admin_screen.dart';
import 'package:sunmi/widgets/comprobantes.dart';
import 'package:sunmi/widgets/superadmin_screen.dart';

import 'widgets/home_screen.dart';
import 'widgets/list_tickets.dart';
import 'package:sunmi/providers/tickets_provider.dart';

//impresora
/* import 'package:sunmi/sunmi_screen.dart';
SunmiScreen(), */
var ticketsProvider = TicketsProvider();
void main() async {
  // Asegúrate de que los widgets estén vinculados

  WidgetsFlutterBinding.ensureInitialized();
  // Registra el adaptador de tu modelo Ticket
  Hive.registerAdapter(TicketAdapter());
  Hive.registerAdapter(CartAdapter());
  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(EmpresaAdapter());
  Hive.registerAdapter(CreditoAdapter());
  await Hive.initFlutter();

  await Hive.openBox<Ticket>('ticketsBox');
  await Hive.openBox<Empresa>('empresa');
  await Hive.openBox<Cart>('carts');
  await Hive.openBox<Credito>('credito');
  
  // Inicia tu aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunmi Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        // Ruta principal que será la pantalla Home
        '/': (context) => const HomeScreen(),
        // Ruta para la pantalla Admin
        '/admin': (context) => AdminScreen(),
        '/superadmin': (context) => SuperAdminScreen(),
        '/comprobantes': (context) => OrdenesScreen(),

        ListarScreen.nameRoute: (context) => ListarScreen(),
      },
    );
  }
}

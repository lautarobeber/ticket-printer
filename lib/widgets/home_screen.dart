import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sunmi/hive/credito.dart';
import 'package:sunmi/hive/empresa.dart';
import 'package:sunmi/providers/credito_provider.dart';
import 'package:sunmi/providers/empresa_provider.dart';
import 'package:sunmi/sunmi.dart';
import 'package:visibility_detector/visibility_detector.dart'; // Importar el paquete
import 'package:sunmi/providers/cart_provider.dart';
import 'package:sunmi/providers/tickets_provider.dart';
import 'package:uuid/uuid.dart';

import 'drawer.dart';
import '/hive/ticket.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Ticket> tickets = []; // Lista para almacenar los tickets
  List<Ticket> cart = []; // Lista para almacenar los tickets en el carrito.
  String? _title;
  String? _pointSale;
  String? _seller;
  double? _creditUsed;
  String? _creditAvailable;
  Sunmi printer = Sunmi();

  double totalMoney = 0.0; // Variable para almacenar la suma total
  var uuid = Uuid();

  var ticketsProvider = TicketsProvider();

  @override
  void initState() {
    super.initState();
    loadTickets();
    _cargarEmpresa();
    _cargarCredito(); // Cargar tickets al iniciar.
    getCreditUsed();
  }

  void getCreditUsed() async {
    // Espera el resultado del Future y asigna el valor a una variable double?
    _creditUsed = await calculateTotalCollected();

    print("Total recolectado: $_creditUsed ");
  }

  Future<void> _cargarCredito() async {
    Credito? credito =
        await getCredito(); // Ahora empresa será de tipo Empresa?

    if (credito != null) {
      setState(() {
        _creditAvailable = credito.credit;
      });
    } else {
      // Manejo en caso de que no se encuentre ninguna empresa
      _creditAvailable = '99999999999999';
    }
  }

  void _cargarEmpresa() async {
    Empresa? empresa =
        await getEmpresa(); // Ahora empresa será de tipo Empresa?

    if (empresa != null) {
      // Si se encontró una empresa, asigna los valores a los controladores
      setState(() {
        _title = empresa.title; // Titulo
        _pointSale = empresa.pointSale; // Punto de venta
        _seller = empresa.seller; // Vendedor
        /* _imageBytes = empresa.imageBytes; */ // Imagen (si es necesaria)
      });
    } else {
      // Manejo en caso de que no se encuentre ninguna empresa
      print('No se encontraron empresas en la base de datos');
    }
  }

  Future<void> loadTickets() async {
    final List<Ticket> newTickets = await ticketsProvider.getTickets();

    // Verificar si los tickets han cambiado y actualiza la lista si es necesario.
    if (newTickets != tickets) {
      setState(() {
        tickets = newTickets;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    ticketsProvider.dispose();
  }

  void _printOrder() async {
    double availableCredit;

    try {
      availableCredit = double.parse(_creditAvailable!);
    } catch (e) {
      print("Error al parsear el crédito disponible: $e");
      return; // Salir si ocurre un error al convertir
    }

    // Verifica si el crédito disponible es menor que el crédito usado
    if (availableCredit <= ((_creditUsed ?? 0.0) + (totalMoney))) {
      // Mostrar un SnackBar en lugar de solo imprimir en la consola
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La orden excede el credito de venta disponible."),
          duration: Duration(seconds: 3), // Duración del SnackBar
        ),
      );
      setState(() {
        cart = []; // Vaciamos el carrito
      });
      return; // Salir sin imprimir si no se cumple la condición
    }

    // Generar el UUID
    var uuid = Uuid().v4();
    print("UUID original: $uuid");

    // Convertir el UUID a bytes
    var uuidBytes = utf8.encode(uuid);

    // Codificar en Base64
    var id_cart = base64UrlEncode(uuidBytes).substring(0, 16);

    bool success = await agregarTicketsAlCarrito(id_cart, cart);
    /* await printer.printTicket(cart, id_cart, _title, _seller, _pointSale); */
    if (success) {
      // Vaciar el carrito en la interfaz
      setState(() {
        cart = []; // Vaciamos el carrito
      });
    }
  }

  void _addTicket(Ticket ticket) {
    setState(() {
      final existingTicketIndex = cart.indexWhere((t) => t.id == ticket.id);

      if (existingTicketIndex == -1) {
        // Si no está en el carrito, agrégalo con cantidad 1
        cart.add(Ticket(
            id: ticket.id,
            name: ticket.name,
            price: ticket.price,
            quantity: 1));
      } else {
        // Si está en el carrito, aumenta la cantidad
        cart[existingTicketIndex].quantity += 1;
      }

      _calculateTotal(); // Recalcular el total
    });
  }

  void _calculateTotal() {
    totalMoney =
        cart.fold(0.0, (sum, ticket) => sum + (ticket.price * ticket.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('home_screen_visibility_detector'),
      onVisibilityChanged: (visibilityInfo) {
        // Si el widget es visible, recargar los tickets
        if (visibilityInfo.visibleFraction > 0.0) {
          loadTickets();
          _cargarCredito(); // Cargar tickets al iniciar.
          getCreditUsed();
          setState(() {
            cart = [];
          }); // Recargar tickets cuando el widget sea visible
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                loadTickets();
                setState(() {
                  cart = [];
                }); // Vaciar carrito y recargar tickets manualmente
              },
            ),
          ],
        ),
        drawer: AppDrawer(loadTickets: loadTickets),
        body: FutureBuilder<List<Ticket>>(
          future: ticketsProvider.getTickets(),
          builder: (context, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator()); // Indicador de carga
            } else if (snapShot.connectionState == ConnectionState.done) {
              return (ticketsProvider.box.length < 1)
                  ? Container(
                      alignment: Alignment.center, // Centra el texto
                      child: const Text(
                        'No hay tickets',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : _getTicketsHome(context); // Mostrar los tickets disponibles
            }
            return Container();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: cart.isNotEmpty
            ? SizedBox(
                width: 200, // Ancho del botón
                height: 50, // Alto del botón
                child: ElevatedButton(
                  onPressed: () async {
                    _printOrder(); // Procesar orden
                  },
                  child: Text(
                    'COBRAR \$${totalMoney.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 77, 232, 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  ListView _getTicketsHome(BuildContext context) {
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, ticketsIndex) {
        var ticketIndividual = tickets[ticketsIndex]; // Ticket actual
        return Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            ticketIndividual.name, // Nombre del ticket
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove,
                            color: Colors.red, size: 46),
                        onPressed: () {
                          _decreaseTicketQuantity(ticketIndividual);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Precio: \$${ticketIndividual.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Cantidad: ${getCartQuantity(ticketIndividual)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _addTicket(
                              ticketIndividual); // Agregar ticket al carrito
                        },
                        child: const Text(
                          'Agregar',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _decreaseTicketQuantity(Ticket ticket) {
    setState(() {
      final existingTicketIndex = cart.indexWhere((t) => t.id == ticket.id);

      if (existingTicketIndex != -1) {
        if (cart[existingTicketIndex].quantity > 1) {
          cart[existingTicketIndex].quantity -= 1;
        } else {
          cart.removeAt(existingTicketIndex);
        }
      }

      _calculateTotal(); // Recalcular total
    });
  }

  int getCartQuantity(Ticket ticket) {
    final cartTicket = cart.firstWhere(
      (t) => t.id == ticket.id,
      orElse: () => Ticket(
          id: ticket.id, name: ticket.name, price: ticket.price, quantity: 0),
    );
    return cartTicket.quantity;
  }
}

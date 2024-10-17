import 'package:flutter/material.dart';
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
  
  double totalMoney = 0.0; // Variable para almacenar la suma total
  var uuid = Uuid();

  var ticketsProvider = TicketsProvider();

  @override
  void initState() {
    super.initState();
    loadTickets(); // Cargar tickets al iniciar.
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
    var id_cart = uuid.v4();

    bool success = await agregarTicketsAlCarrito(id_cart, cart);

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

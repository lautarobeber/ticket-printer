import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunmi/hive/cart.dart';
import 'package:sunmi/hive/ticket.dart';
import 'package:uuid/uuid.dart';

Future<bool> agregarTicketsAlCarrito(String cartId, List<Ticket> cart) async {
  // Abrir la caja de carritos
  var carritoBox = await Hive.openBox<Cart>('carts');

  // Obtener el carrito del usuario
  var carrito = carritoBox.get(cartId);

  // Verificar si el carrito ya existe
  if (carrito == null) {
    // Si no existe, lo creamos
    carrito = Cart(cartId: cartId, items: [], total: 0);
  }

  double total = carrito.total; // Usar el total existente

  // Recorre la lista de tickets
  for (Ticket ticket in cart) {
    // Buscar si el ticket ya existe en el carrito
    var existingItem = carrito.items.firstWhere(
      (item) => item.ticketId == ticket.id,
      orElse: () => CartItem(
          ticketId: '', // ID temporal que no se usará, puedes ajustarlo
          cantidad: 0,
          price: 0,
          name: ''), // Objeto temporal que no se añadirá a la lista
    );

    if (existingItem.ticketId.isNotEmpty) {
      // Si el ticket ya existe, incrementamos la cantidad
      existingItem.cantidad += ticket.quantity;
    } else {
      // Si el ticket no existe en el carrito, lo agregamos con la cantidad correspondiente
      carrito.items.add(CartItem(
          ticketId: ticket.id,
          cantidad: ticket.quantity,
          price: ticket.price,
          name: ticket.name));
    }

    // Calcular el total por cada ticket (cantidad * precio)
    total += ticket.quantity * ticket.price;
  }

  // Actualizar el total del carrito
  carrito.total = total; // Formatear el total con 2 decimales
  var itemsList = carrito.items;

  // Imprimir los items del carrito
  
  for (var item in itemsList) {
    print(
        'Ticket ID: ${item.ticketId}, Cantidad: ${item.name}, Precio: ${item.price}');
  }
  // Actualizar el carrito en Hive
  await carritoBox.put(cartId, carrito);

  return true; // Indica que se completó la operación
}

Future<List<Map<String, dynamic>>> obtenerOrdenesConTickets() async {
  // Comprobamos si la caja de tickets ya está abierta
  if (!Hive.isBoxOpen('ticketsBox')) {
    await Hive.openBox<Ticket>('ticketsBox');
  }

  // Verificamos si la caja de carritos ya está abierta
  if (!Hive.isBoxOpen('carts')) {
    await Hive.openBox<Cart>('carts');
  }

  // Accedemos a las cajas
  var ticketBox = Hive.box<Ticket>('ticketsBox');
  var carritoBox = Hive.box<Cart>('carts');
  print('Número de carritos guardados: ${carritoBox.values.length}');
  // Lista para almacenar los carritos con sus tickets
  List<Map<String, dynamic>> ordenesConTickets = [];
  for (var carrito in carritoBox.values) {
    print('Carrito: ${carrito.cartId}');
    print('Items: ${carrito.items}');
  }
  // Recorremos todos los carritos guardados
  for (var carrito in carritoBox.values) {
    // Obtenemos los detalles de los tickets para cada carrito
    List<Map<String, dynamic>> ticketsConCantidad = carrito.items.map((item) {
      var ticket = ticketBox.get(item.ticketId);
      print('hola');
      // Devolvemos la cantidad y el precio junto con el ticket

      return {
        'ticketId': item.ticketId,
        'cantidad': item.cantidad,
        'price': item.price,
        'name': item.name,
        'ticket': ticket, // opcional, si necesitas más detalles del ticket
      };
    }).toList();

    // Añadimos el carrito con sus tickets y detalles a la lista
    ordenesConTickets.add({
      'cartId': carrito.cartId,
      'tickets': ticketsConCantidad,
    });
  }
  print('Número de carritos guardados: ${ordenesConTickets}');
  return ordenesConTickets;
}

Future<bool> vaciarCart() async {
  // Abrir la caja de carritos
  var carritoBox = await Hive.openBox<Cart>('carts');

  // Verificar si el carrito existe

  // Eliminar el carrito especificado
  await carritoBox.clear();
  print('Carrito  ha sido vaciado.');

  return true; // Indica que la operación se completó con éxito
}

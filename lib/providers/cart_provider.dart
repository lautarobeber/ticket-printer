import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunmi/hive/cart.dart';
import 'package:sunmi/hive/ticket.dart';
import 'package:uuid/uuid.dart';

Future<bool> agregarTicketsAlCarrito(String cartId, List<Ticket> cart) async {
  // Abrir la caja de carritos
  var uuid = Uuid();
  var carritoBox = await Hive.openBox<Cart>('carts');

  // Obtener el carrito del usuario
  var carrito = carritoBox.get(cartId);

  // Verificar si el carrito ya existe
  if (carrito == null) {
    // Si no existe, lo creamos
    carrito = Cart(cartId: cartId, items: [], total: '0');
  }

  double total = 0;

  // Recorre la lista de tickets
  for (Ticket ticket in cart) {
    // Buscar si el ticket ya existe en el carrito
    var existingItem = carrito.items.firstWhere(
      (item) => item.ticketId == ticket.id,
      orElse: () => CartItem(
          ticketId: uuid.v4(),
          cantidad: 0,
          price: 0), // Si no existe, devuelve un CartItem temporal
    );

    if (existingItem.ticketId != -1) {
      // Si el ticket ya existe, incrementamos la cantidad
      existingItem.cantidad += ticket.quantity;
    } else {
      // Si el ticket no existe en el carrito, lo agregamos con la cantidad correspondiente
      carrito.items
          .add(CartItem(ticketId: ticket.id, cantidad: ticket.quantity, price: ticket.price));
    }

    // Calcular el total por cada ticket (cantidad * precio)
    total += ticket.quantity * ticket.price;
  }

  // Actualizar el total del carrito
  carrito.total = total.toStringAsFixed(2); // Formatear el total con 2 decimales

  // Actualizar el carrito en Hive
  carritoBox.put(cartId, carrito);

  return true; // Indica que se completó la operación
}

Future<List<Map<String, dynamic>>> obtenerOrdenesConTickets() async {
  // Comprobamos si la caja de tickets ya está abierta
  if (!Hive.isBoxOpen('ticketsBox')) {
    // La caja ya está abierta, así que no necesitas abrirla de nuevo
    print('La caja "ticketsBox" ya está abierta.');
  } else {
    await Hive.openBox<Ticket>('ticketsBox');
  }

  // Verificamos si la caja de carritos ya está abierta
  if (!Hive.isBoxOpen('carts')) {
    await Hive.openBox<Cart>('carts');
  }


  // Accedemos a las cajas
  var ticketBox = Hive.box<Ticket>('ticketsBox');
  var carritoBox = Hive.box<Cart>('carts');

  // Lista para almacenar los carritos con sus tickets
  List<Map<String, dynamic>> ordenesConTickets = [];

  // Recorremos todos los carritos guardados
  for (var carrito in carritoBox.values) {
    // Obtenemos los detalles de los tickets para cada carrito
    List<Map<String, dynamic>> ticketsConCantidad = carrito.items.map((item) {
      var ticket = ticketBox.get(item.ticketId);
      return {
        'ticket': ticket,
        'cantidad': item.cantidad,
      };
    }).toList();

    // Añadimos el carrito con sus tickets a la lista
    ordenesConTickets.add({
      'cartId': carrito.cartId,
      /* 'fecha': carrito.fecha, */ // Asegúrate de que 'fecha' esté disponible en el carrito
      'tickets': ticketsConCantidad,
    });
  }

  print('Número de órdenes cargadas: ${ordenesConTickets.length}');

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
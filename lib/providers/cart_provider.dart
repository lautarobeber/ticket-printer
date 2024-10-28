import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sunmi/hive/cart.dart';
import 'package:sunmi/hive/empresa.dart';
import 'package:sunmi/hive/ticket.dart';
import 'package:sunmi/sunmi.dart';
import 'package:uuid/uuid.dart';

Future<bool> agregarTicketsAlCarrito(String cartId, List<Ticket> cart) async {
  // Abrir la caja de carritos
  var carritoBox = await Hive.openBox<Cart>('carts');

  // Obtener el carrito del usuario
  var carrito = carritoBox.get(cartId);

  DateTime now = DateTime.now(); 

  // Verificar si el carrito ya existe
  if (carrito == null) {
    // Si no existe, lo creamos
    carrito = Cart(cartId: cartId, items: [], total: 0, date: now);
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


  // Imprimir los items del carrito

  
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

  // Lista para almacenar los carritos con sus tickets
  List<Map<String, dynamic>> ordenesConTickets = [];

  // Recorremos todos los carritos guardados
  for (var carrito in carritoBox.values) {
    // Obtenemos los detalles de los tickets para cada carrito
    List<Map<String, dynamic>> ticketsConCantidad = carrito.items.map((item) {
      var ticket = ticketBox.get(item.ticketId);
      
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
      'date': carrito.date,
      'tickets': ticketsConCantidad,
    });
  }
 
  return ordenesConTickets;
}

Future<bool> deleteOrderById(String cartId) async {
  // Abrir la caja de carritos
  var carritoBox = await Hive.openBox<Cart>('carts');

  // Verificar si el carrito existe
  if (!carritoBox.containsKey(cartId)) {
    print('Carrito no encontrado');
    return false; // Indica que el carrito no fue encontrado
  }

  // Eliminar el carrito especificado
  await carritoBox.delete(cartId);
  print('Carrito con ID $cartId eliminado');

  return true; // Indica que la operación se completó con éxito
}

Future<bool> vaciarCart() async {
  // Abrir la caja de carritos
  var carritoBox = await Hive.openBox<Cart>('carts');

  // Verificar si el carrito existe

  // Eliminar el carrito especificado
  await carritoBox.clear();
  print('Comprobantes eliminados');

  return true; // Indica que la operación se completó con éxito
}

Future<Map<String, Map<String, dynamic>>> getCajaZ() async {
  // Comprobamos si las cajas están abiertas y las abrimos si es necesario.

  Sunmi printer = Sunmi();
  if (!Hive.isBoxOpen('ticketsBox')) {
    await Hive.openBox<Ticket>('ticketsBox');
  }
  if (!Hive.isBoxOpen('carts')) {
    await Hive.openBox<Cart>('carts');
  }
 

  // Accedemos a las cajas
  var ticketBox = Hive.box<Ticket>('ticketsBox');
  var carritoBox = Hive.box<Cart>('carts');
  var empresaBox = Hive.box<Empresa>('empresa');

  // Obtener datos empresa
  Empresa? primeraEmpresa =
      empresaBox.values.isNotEmpty ? empresaBox.values.first : null;

  if (primeraEmpresa != null) {
    print("Empresa encontrada: ${primeraEmpresa.title}");
  } else {
    print("No se encontró ninguna empresa.");
  }

  var empresa = {
    'pointSale': primeraEmpresa?.pointSale ?? '',
    'title': primeraEmpresa?.title ?? '',
    'seller': primeraEmpresa?.seller ?? ''
  };

  // Mapa para almacenar los tickets por ID, con nombre, cantidad y precio
  Map<String, Map<String, dynamic>> ticketsZ = {};

  // Inicializamos los tickets con cantidad 0 y el precio
  for (var ticket in ticketBox.values) {
    ticketsZ[ticket.id] = {
      'nombre': ticket.name, // Almacenamos el nombre del ticket
      'cantidad': 0, // Inicializamos la cantidad en 0
      'precio': ticket.price // Guardamos el precio del ticket
    };
  }

  // Iteramos sobre cada carrito para sumar las cantidades de los tickets
  for (var orden in carritoBox.values) {
    // Dentro de cada carrito, recorremos los tickets
    for (var ticket in orden.items) {
      String ticketId = ticket.ticketId;
      int cantidad = ticket.cantidad;

      // Encontramos el ticket por su ID
      Ticket? ticketInBox = ticketBox.values.firstWhere(
        (t) => t.id == ticketId,
        orElse: () => Ticket(
            id: ticketId,
            name: 'Unknown',
            price: 0), // Proporciona un ticket ficticio si no se encuentra
      );

      // Si el ticket existe en el box, actualizamos su cantidad en el mapa
      if (ticketInBox.name != 'Unknown') {
        ticketsZ[ticketInBox.id]!['cantidad'] =
            (ticketsZ[ticketInBox.id]!['cantidad'] ?? 0) + cantidad;
        ticketsZ[ticketInBox.id]!['precio'] = ticketInBox.price;
      }
    }
  }

 



  return ticketsZ; // Retorna los tickets con sus cantidades y precios
}


Future<double> calculateTotalCollected() async {
  // Verificamos si la caja 'carts' está abierta y la abrimos si es necesario
  if (!Hive.isBoxOpen('carts')) {
    await Hive.openBox<Cart>('carts');
  }

  // Accedemos a la caja 'carts'
  var carritoBox = Hive.box<Cart>('carts');

  // Variable para acumular el total de dinero recolectado
  double totalDineroRecolectado = 0.0;

  // Recorremos todos los carritos y sumamos el total de cada uno
  for (var carrito in carritoBox.values) {
    totalDineroRecolectado += carrito.total;
  }

 

  // Retornamos el total recolectado
  return totalDineroRecolectado;
}
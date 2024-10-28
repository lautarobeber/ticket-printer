import 'package:hive_flutter/hive_flutter.dart';


part 'cart.g.dart';



@HiveType(typeId: 1)
class Cart extends HiveObject {
  @HiveField(0)
  final String cartId;

  @HiveField(1)
  final List<CartItem> items;

  @HiveField(2)
  double total;

  @HiveField(3) // Agrega el decorador para el nuevo campo
  final DateTime? date; // Permite que sea nulo

  Cart({
    required this.cartId,
    required this.items,
    required this.total,
    this.date, // No es requerido, así que no es necesario el "required"
  });
}
@HiveType(typeId: 2)
class CartItem extends HiveObject{
  @HiveField(0)
  final String ticketId; //cambiar a string


  @HiveField(1)
  int cantidad;
  @HiveField(2)
  double price;
  
  @HiveField(3)
  final String name;


  CartItem({
    required this.ticketId,
    required this.price,
    required this.cantidad,
    required this.name,
  });
}

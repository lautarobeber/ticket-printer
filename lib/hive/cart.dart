import 'package:hive_flutter/hive_flutter.dart';


part 'cart.g.dart';



@HiveType(typeId: 1)
class Cart extends HiveObject {
  @HiveField(0)
  final String cartId;

  @HiveField(1)
  final List<CartItem> items;
  @HiveField(2)
   String total;

  Cart({
    required this.cartId,
    required this.items,
    required this.total,
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

  CartItem({
    required this.ticketId,
    required this.price,
    required this.cantidad,
  });
}

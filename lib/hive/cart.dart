import 'package:hive_flutter/hive_flutter.dart';


part 'cart.g.dart';



@HiveType(typeId: 1)
class Cart extends HiveObject {
  @HiveField(0)
  final String cartId;

  @HiveField(1)
  final List<CartItem> items;

  Cart({
    required this.cartId,
    required this.items,
  });
}

@HiveType(typeId: 2)
class CartItem extends HiveObject{
  @HiveField(0)
  final int ticketId;

  @HiveField(1)
  int cantidad;

  CartItem({
    required this.ticketId,
    required this.cantidad,
  });
}

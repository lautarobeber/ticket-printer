import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunmi/hive/cart.dart';
import 'package:sunmi/hive/ticket.dart';

class HiveService {
  static Box<Ticket>? ticketBox;
  static Box<Cart>? carritoBox;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    ticketBox = await Hive.openBox<Ticket>('ticketsBox');
    carritoBox = await Hive.openBox<Cart>('carts');
  }
}
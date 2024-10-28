import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunmi/hive/cart.dart';
import 'package:sunmi/hive/credito.dart';
import 'package:sunmi/hive/empresa.dart';
import 'package:sunmi/hive/ticket.dart';

class HiveService {
  static Box<Ticket>? ticketBox;
  static Box<Cart>? carritoBox;
  static Box<Empresa>? empresaBox;
  static Box<Credito>? creditoBox;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    ticketBox = await Hive.openBox<Ticket>('ticketsBox');
    carritoBox = await Hive.openBox<Cart>('carts');
    empresaBox = await Hive.openBox<Empresa>('empresa');
    creditoBox = await Hive.openBox<Credito>('credito');
  }
}

import "package:hive_flutter/hive_flutter.dart";
import "package:hive/hive.dart";
part 'ticket.g.dart';

@HiveType(typeId:0)
class Ticket extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  double price;
  @HiveField(3)
  int quantity;


  Ticket(
      {required this.id,
      required this.name,
      required this.price,
      this.quantity = 0});


}

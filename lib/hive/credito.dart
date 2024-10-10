import "package:hive_flutter/hive_flutter.dart";
import "package:hive/hive.dart";
part 'credito.g.dart';

@HiveType(typeId:4)
class Credito extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String credit;
  


  Credito(
      {required this.id,
      required this.credit,
     });


}

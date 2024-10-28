import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'empresa.g.dart'; // Esto es necesario para generar el adaptador automáticamente

@HiveType(typeId: 3)
class Empresa extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;
  
  @HiveField(2)
  String pointSale;

  @HiveField(3)
  String seller;

  @HiveField(4)
  Uint8List? imageBytes; // Ahora es opcional, puede ser null

  Empresa({
    required this.id,
    required this.title,
    this.imageBytes, // No es requerido
    required this.pointSale,
    required this.seller,
  });
}
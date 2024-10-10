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
  Uint8List imageBytes; // Aquí almacenamos la imagen en formato Uint8List

  Empresa({
    required this.id,
    required this.title,
    required this.imageBytes,
  });
}
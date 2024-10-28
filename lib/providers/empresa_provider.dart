import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunmi/hive/empresa.dart';

Future<bool> agregarEmpresa(Empresa empresaData) async {
  try {
    // Abrir la caja de Hive donde se almacenarán las empresas
    var empresaBox = await Hive.openBox<Empresa>('empresa');

    // Guardar la empresa utilizando el id de la empresa como clave
    await empresaBox.put(empresaData.id, empresaData);

    // Cerrar la caja después de agregar el ticket
    await empresaBox.close();

    // Retornar true si todo salió bien
    return true;
  } catch (e) {
    print("Error al agregar empresa al carrito: $e");
    return false; // En caso de error, retornamos false
  }
}

Future<Empresa?> getEmpresa() async {
  // Abrir la caja de Hive
  var empresaBox = await Hive.openBox<Empresa>('empresa');

  // Obtener los valores de la caja
  final empresas = empresaBox.values.toList();

  // Verificar si hay empresas y devolver la primera
  
  
  // Si hay empresas, retornar la primera, de lo contrario retornar null
  return empresas.isNotEmpty ? empresas.first : null;
}
Future<Empresa?> vaciarEmpresa() async {
  // Abrir la caja de Hive
  var empresaBox = await Hive.openBox<Empresa>('empresa');

  // Obtener los valores de la caja
  await empresaBox.clear();

  // Verificar si hay empresas y devolver la primera
  print('vacioado');
  
  // Si hay empresas, retornar la primera, de lo contrario retornar null
  
}

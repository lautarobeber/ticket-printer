import 'package:hive/hive.dart';
import 'package:sunmi/hive/credito.dart';

Future<bool> agregarCredito(Credito creditoData) async {
  try {
    // Abrir la caja de Hive donde se almacenarán las empresas

    if (!Hive.isBoxOpen('credito')) {
      await Hive.openBox<Credito>('credito');
    }
    var creditoBox = Hive.box<Credito>('credito');

    // Guardar la empresa utilizando el id de la empresa como clave
    await creditoBox.put(creditoData.id, creditoData);

    // Cerrar la caja después de agregar el ticket
    await creditoBox.close();

    // Retornar true si todo salió bien
    return true;
  } catch (e) {
    print("Error al agregar el credito maximo: $e");
    return false; // En caso de error, retornamos false
  }
}

Future<Credito?> getCredito() async {
  // Abrir la caja de Hive
  var empresaBox = await Hive.openBox<Credito>('credito');

  // Obtener los valores de la caja
  final empresas = empresaBox.values.toList();

  // Verificar si hay empresas y devolver la primera
  print('Número de creditos cargados: ${empresas.length}');
  
  // Si hay empresas, retornar la primera, de lo contrario retornar null
  return empresas.isNotEmpty ? empresas.first : null;
}

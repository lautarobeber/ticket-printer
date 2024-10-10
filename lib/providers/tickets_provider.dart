import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunmi/hive/ticket.dart';

class TicketsProvider with ChangeNotifier {
  late Box<Ticket> box; // Especifica el tipo de Box

  // Constructor que inicializa la caja
  TicketsProvider() {
    box = Hive.box<Ticket>('ticketsBox'); // Accede a la caja ya abierta
  }

  Future<bool> addTicket(Ticket ticket) async {
    await box.put(ticket.id, ticket);
    notifyListeners();
    return true;
  }

 Future<List<Ticket>> getTickets() async {
  // Simulamos un pequeño retraso para simular una operación asincrónica
  await Future.delayed(Duration(milliseconds: 100));
  print('se recuperaron ${box.values.length}');
  // Obtener los tickets de la base de datos Hive
  return box.values.toList();
}

  Future<bool> deleteTicket(String id) async {
    if (box.containsKey(id)) {
      await box.delete(id); // Elimina el ticket por su ID
      notifyListeners();
      return true;
    } else {
      print('El ID no existe');
      return false;
    }
  }

  Future<void> vaciarBox() async {
    await box.clear(); // Elimina todos los elementos del box
    print('El box ha sido vaciado.');
  }

  Future<bool> updateTicket(String id, Ticket ticket) async {
    await box.put(id, ticket); // Actualizar el ticket con la misma clave (ID)
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    super.dispose(); // Asegúrate de llamar a super.dispose() también
  }
}
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class Sunmi {
  // initialize sunmi printer
  Future<void> initialize() async {
    await SunmiPrinter.bindingPrinter();
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  }

  Future<void> printLogoImage() async {
    await SunmiPrinter.lineWrap(1); // crea un espacio de una línea
    Uint8List byte = await _getImageFromAsset('assets/250.png');

    // Redimensionar la imagen antes de imprimirla
    Uint8List resizedImage = await _resizeImage(
        byte, 200, 200); // Cambia los valores a lo que necesites

    await SunmiPrinter.printImage(resizedImage);
    await SunmiPrinter.lineWrap(1); // crea un espacio de una línea
  }

// Función para leer el archivo de imagen como bytes
  Future<Uint8List> readFileBytes(String path) async {
    ByteData fileData = await rootBundle.load(path);
    Uint8List fileUnit8List = fileData.buffer
        .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
    return fileUnit8List;
  }

// Función para obtener la imagen desde los assets
  Future<Uint8List> _getImageFromAsset(String iconPath) async {
    return await readFileBytes(iconPath);
  }

// Función para redimensionar la imagen
  Future<Uint8List> _resizeImage(
      Uint8List imageBytes, int width, int height) async {
    // Decodifica la imagen a partir de bytes
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null)
      return imageBytes; // Si la imagen no se puede decodificar, retorna los bytes originales

    // Redimensiona la imagen
    img.Image resizedImage =
        img.copyResize(image, width: width, height: height);

    // Codifica la imagen redimensionada de vuelta a bytes
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  // print text passed as parameter
  Future<void> printText(String text) async {
    // creates one line space
    await SunmiPrinter.printText(text,
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ));
    // creates one line space
  }

  // print text as qrcode
  Future<void> printQRCode(String text) async {
    // set alignment center
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.lineWrap(1); // creates one line space
    await SunmiPrinter.printQRCode(text);
    await SunmiPrinter.lineWrap(4); // creates one line space
  }

  // print row and 2 columns
  Future<void> printRowAndColumns(
      {String? column1 = "column 1",
      String? column2 = "column 2",
      String? column3 = "column 3"}) async {
    // creates one line space

    // set alignment center
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    // prints a row with 3 columns
    // total width of columns should be 30
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "$column1",
        width: 10,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
        text: "$column2",
        width: 10,
        align: SunmiPrintAlign.CENTER,
      ),
      ColumnMaker(
        text: "$column3",
        width: 10,
        align: SunmiPrintAlign.RIGHT,
      ),
    ]);
    /* await SunmiPrinter.printText("--------------------------------",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        )); */
    // creates one line space
  }

  /* its important to close the connection with the printer once you are done */
  Future<void> closePrinter() async {
    await SunmiPrinter.unbindingPrinter();
  }

  // print one structure
  Future<void> printReceipt(ticketsZ, pointSale, seller) async {
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await initialize();
    /* await printLogoImage(); */
    await SunmiPrinter.printText("RESUMEN CAJA",
        style: SunmiStyle(
          fontSize: SunmiFontSize.LG,
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ));
    await SunmiPrinter.printText("---NO VALIDO COMO FACTURA---",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ));
    await SunmiPrinter.printText("Fecha: $formattedDate",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    await SunmiPrinter.printText("Punto de venta: $pointSale",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    await SunmiPrinter.printText("--------------------------------",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    // Imprimir la cabecera
    await printRowAndColumns(
        column1: "Artículo", column2: "Cantidad", column3: "Total");
    double totalGeneral = 0;
    int totalCantidad = 0;
    // Iterar sobre los tickets y imprimir cada uno
    for (var entry in ticketsZ.entries) {
      // entry.key es la clave (por ejemplo, 1, 2, etc.)
      // entry.value es el Map<String, dynamic> asociado a la clave
      var ticketDetails = entry.value;

      String ticketName =
          ticketDetails['nombre'] as String; // Obtener el nombre
      int quantity = ticketDetails['cantidad'] as int; // Obtener la cantidad
      double price = ticketDetails['precio'] as double; // Obtener el precio

      double totalPrice = quantity * price;
      totalGeneral += totalPrice;
      totalCantidad += quantity;
      // Imprimir la fila para el ticket
      await printRowAndColumns(
        column1: ticketName,
        column2: quantity.toString(),
        column3: "\$${totalPrice.toStringAsFixed(2)}",
      );
    }
    await SunmiPrinter.printText("--------------------------------",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    await printRowAndColumns(
        column1: "TOTAL",
        column2: totalCantidad.toString(),
        column3: "\$${totalGeneral.toStringAsFixed(2)}");
    await printQRCode(
        "Entradas Compradas: ${totalCantidad.toStringAsFixed(0)} Precio: \$${totalGeneral.toStringAsFixed(2)}");
    await SunmiPrinter.printText("--------------------------------",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    // await SunmiPrinter.cut(); // Descomenta si deseas cortar el papel
    await closePrinter();
  }

  // Método para imprimir un Z contable
  Future<void> printTicket(cart,id_cart, _title, _seller, _pointSale) async {
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await initialize();
    /* await printLogoImage(); */
    await SunmiPrinter.printText("$_title",
        style: SunmiStyle(
          fontSize: SunmiFontSize.LG,
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ));
    await SunmiPrinter.printText("---NO VALIDO COMO FACTURA---",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ));
    await SunmiPrinter.printText("Fecha: $formattedDate",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    await SunmiPrinter.printText("ID: $id_cart",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    await SunmiPrinter.printText("Vendedor: $_seller",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));

    await SunmiPrinter.printText("--------------------------------",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    // Imprimir la cabecera
    await printRowAndColumns(
        column1: "Artículo", column2: "Cantidad", column3: "Total");
    await SunmiPrinter.printText("--------------------------------",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    double totalGeneral = 0;
    double totalCantidad = 0;
    // Iterar sobre los tickets y imprimir cada uno
    for (var entry in cart) {
      // entry.key es la clave (por ejemplo, 1, 2, etc.)
      // entry.value es el Map<String, dynamic> asociado a la clave

      double totalPrice = entry.quantity * entry.price;
      totalGeneral += totalPrice;
      totalCantidad += entry.quantity;
      // Imprimir la fila para el ticket
      await printRowAndColumns(
        column1: entry.name,
        column2: entry.quantity.toString(),
        column3: "\$${totalPrice.toStringAsFixed(2)}",
      );
    }
    await SunmiPrinter.printText("--------------------------------",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    await printRowAndColumns(
        column1: "TOTAL",
        column2: totalCantidad.toStringAsFixed(0),
        column3: "\$${totalGeneral.toStringAsFixed(2)}");
    await printQRCode(
        "Entradas Vendidas: ${totalCantidad.toString()} Recaudacion: \$${totalGeneral.toStringAsFixed(2)}");
    await SunmiPrinter.printText("--------------------------------",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ));
    // await SunmiPrinter.cut(); // Descomenta si deseas cortar el papel
    await closePrinter();
  }
}
